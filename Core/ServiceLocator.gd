# Core/ServiceLocator.gd
extends Node

var _services: Dictionary = {}

func register_service(service_name: StringName, service: Variant) -> void:
	if _services.has(service_name):
		push_warning("ServiceLocator: Overwriting service %s" % service_name)
	_services[service_name] = service

func get_service(service_name: StringName) -> Variant:
	assert(_services.has(service_name), "ServiceLocator: Service %s is not registered!" % service_name)
	return _services[service_name]

func unregister_service(service_name: StringName) -> void:
	_services.erase(service_name)
