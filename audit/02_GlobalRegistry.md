# GlobalRegistry.gd — God Object Analysis

> Файл: `GlobalRegistry.gd` — 3018 строк

## 1. Обзор

Центральный реестр для **~50 типов сущностей** в игре. Второй по размеру God Object в проекте. Содержит ~80 словарей/массивов хранения, 52 функции `registerFolder`, 29 функций `create`, 127 функций `getX`.

**Используется в 545 файлах** (2543 вызова `GlobalRegistry.`).

## 2. Типы сущностей

| Категория | Типы | Примеры |
|---|---|---|
| **Персонажи** | characters, dynamicCharacters, datapackCharacters | NPC, игрок, динамические |
| **Части тела** | bodyparts, partSkins | Head, Penis, Vagina, Ears, Tail |
| **Предметы** | items, buffs, restraints, lootTables, lootLists | Оружие, одежду, ограничения |
| **Боевая система** | attacks, statusEffects, damageTypes | Урон, баффы, статусы |
| **Навыки** | skills, perks, stats, lustTopics | Навыки, перки, характеристики |
| **Секс-система** | sexActivities, sexGoals, sexTypes, fetishes, sexReactions | Активности, цели, типы |
| **Мир** | stageScenes, mapFloors, worldEdits, imagePacks | Сцены, карты, изображения |
| **Моды** | datapacks, modules, gameExtenders, interactions | Плагины, датапаки |
| **Квесты** | quests, events, globalTasks | Квесты, события |
| **NPC** | pawnTypes, fightClubFighters, computers | Типы NPC, компьютеры |
| **Прочее** | fluids, species, speechModifiers, repStats, recruitSystem | Жидкости, виды, речь |

## 3. Паттерн дублирования (Copy-Paste)

### 3.1 `registerFolder()` — повторяется 52 раза

Каждая функция — почти идентичная копия:

```gdscript
# Повторяется 52 раза (строки 897, 956, 985, 1074, 1119, ...)
func registerXxxFolder(folder: String):
    var dir = Directory.new()
    if dir.open(folder) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir():
                pass
            else:
                if(file_name.get_extension() == "gd"):
                    var full_path = folder.plus_file(file_name)
                    registerXxx(full_path)
            file_name = dir.get_next()
    else:
        Log.printerr("An error occurred when trying to access the path "+folder)
```

### 3.2 `register()` (single item) — повторяется ~40 раз

```gdscript
# Повторяется ~40 раз
func registerXxx(path: String):
    var loadedClass = load(path)
    var object = loadedClass.new()
    xxxStorage[object.id] = object  # или loadedClass — несогласованно
```

### 3.3 `getX()` — повторяется ~40 раз

```gdscript
# Повторяется ~40 раз
func getXxx(id: String):
    if(xxxStorage.has(id)):
        return xxxStorage[id]
    else:
        Log.printerr("ERROR: xxx with the id "+id+" wasn't found")
        return null
```

## 4. Подсчёт дублирования

| Паттерн | Количество | Строк на копию | Итого строк |
|---|---|---|---|
| `registerXxxFolder()` | 52 | ~15 | ~780 |
| `registerXxx()` | 40 | ~5 | ~200 |
| `getXxx()` | 40 | ~7 | ~280 |
| `createXxx()` | 29 | ~5 | ~145 |
| **Итого** | **161** | — | **~1405** |

**~47% файла** — это скопированный шаблонный код.

## 5. Система кэширования (строки 394-461, 2946-3001)

Двунаправленный кэш path-to-ID / ID-to-path для сцен, персонажей и stage scenes.

```gdscript
# Кэш сохраняется в user://registryCache.json
# При старте загружается, при завершении сохраняется
# Lazy-loading: скрипты могут быть null до первого обращения
```

Особенности:
- Включён по умолчанию в редакторе, отключён на HTML5
- Использует `var2str`/`str2var` для персистентности
- Файл-замок (`load lock`) обнаруживает краши при инициализации

## 6. Загрузка модов (строки 347-392)

Сканирует `user://mods` на `.pck`/`.zip` файлы. `loadModOrder()` итерирует упорядоченный массив, вызывает `ProjectSettings.load_resource_pack()`. Без dependency resolution. В редакторе отключено (ограничение Godot 3.x).

## 7. Загрузка датапаков (строки 2455-2490)

Сканирует на `.res`/`.tres` файлы, кастует в `DatapackResource`, оборачивает в `Datapack`. Проверяет коллизии ID. Проще чем загрузка модов — просто загрузка ресурсов.

## 8. Обработка ошибок

71 вызов `Log.printerr("ERROR: ...")` — каждый getter/create логирует и возвращает null при отсутствии ID. Нет исключений, нет повторных попыток.

**Баг копирования**: `getStat()` (строка 1421) говорит "quest with the id" вместо "stat with the id" — ошибка в сообщении об ошибке.

## 9. Рекомендации

### 9.1 Устранение дублирования

Заменить 161 копию шаблона на один generic-реестр:

```gdscript
class Registry:
    var storage: Dictionary = {}
    var name: String
    
    func register(id: String, data):
        storage[id] = data
    
    func get(id: String):
        if storage.has(id):
            return storage[id]
        Log.printerr("ERROR: " + name + " with id " + id + " not found")
        return null
    
    func registerFolder(folder: String):
        # Единая реализация для всех типов
```

### 9.2 Типобезопасность

Заменить строковые ID на `Resource`-ссылки или `enum`-ы, где это возможно.

### 9.3 Разделение ответственности

Вынести:
- `ModManager` — загрузка модов
- `DatapackManager` — загрузка датапаков
- `CacheManager` — кэширование
- `RegistryManager` — единый реестр с generic API

## 10. Ключевые проблемы

1. **~47% файла** — скопированный шаблонный код
2. **~50 типов сущностей** в одном классе — SRP violation
3. **Строковые ID** без валидации — silent bugs
4. **Несогласованное хранение** — иногда `object`, иногда `loadedClass`
5. **Нет generic API** — каждый тип требует отдельный набор методов
