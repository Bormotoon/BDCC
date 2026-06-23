# Sex Toy Integration — Analysis

> `Util/SexToySupport/` — 7 core + 3 backend файлов

## 1. Обзор

Интеграция с физическими секс-игрушками через 3 бэкенда. Игровые события маппятся на паттерны вибрации через кривые интенсивности.

## 2. Архитектура

```
SexToyManager (254 строки) — координатор
  ├── ButtplugIO Backend (366 строк) — Buttplug.IO v4 WebSocket
  ├── LovenseConnect Backend (414 строк) — Lovense Connect app
  └── XToysApp Backend (157 строк) — XToys.App (e-stim support)
```

### 2.1 SexToyManager

```gdscript
# Управляет бэкендами, игрушками, группами и gameplay triggers
func sendTrigger(trigger: SexToyTrigger):
    # Игровое событие → вибрация через кривые
```

### 2.2 Buttplug.IO Backend

- Полная реализация Buttplug.IO v4 протокола
- WebSocket соединение
- Device discovery, vibration output
- Rate limit: 20 запросов/сек
- Request queue с batching

### 2.3 LovenseConnect Backend

- Lovense Connect app интеграция
- 414 строк — самый большой бэкенд

### 2.4 XToysApp Backend

- 157 строк — самый компактный
- Поддержка e-stim toys

## 3. Gameplay Triggers

Default gameplay config — hardcoded JSON blob с curve points для генерации паттернов:

```gdscript
# События: OnOrgasm, OnPenetration, OnLoseConsciousness и т.д.
# Маппятся на: vibration pattern + intensity + duration через кривые
```

### 3.1 Интеграция с SexEngine

Минимальная на уровне движка — триггеры вызываются из `SexSubInfo`:

```gdscript
if(isCon && charID == "pc" && getConsciousness() <= 0.0):
    SexToyManager.sendTrigger(SexToyTrigger.OnLoseConsciousness)
```

### 3.2 UI панель

Встроенная панель в главном меню ("Buttplug.io" кнопка) для настройки:
- Какие игровые события триггерят игрушки
- Какие игрушки реагируют
- Интенсивность и паттерны

## 4. Сильные стороны

1. **3 бэкенда** — широкая поддержка hardware
2. **Кастомизируемость** — полный контроль над триггерами
3. **Curve-based patterns** — гибкая настройка интенсивности
4. **Встроенная UI** — не требует внешних инструментов

## 5. Слабые стороны

1. **Hardcoded config** — default JSON blob в коде
2. **Rate limiting** — 20 req/s может быть мало для сложных паттернов
3. **Нет error recovery** — WebSocket disconnect = потеря соединения
4. **Минимальная интеграция** — триггеры вызываются вручную из разных мест

## 6. Рекомендации

| Приоритет | Действие |
|---|---|
| **Средний** | Вынести default config в ресурсный файл |
| **Средний** | Добавить reconnect logic для WebSocket |
| **Низкий** | Централизовать вызовы sendTrigger через event bus |
