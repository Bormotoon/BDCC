# Core/ServiceLocator.gd
extends Node

## Simple DI container. Replaces the old GM monolith.
var _services: Dictionary = {}

## Registers a service (manager) in the locator
func register_service(service_name: StringName, service_node: Node) -> void:
	if _services.has(service_name):
		push_warning("ServiceLocator: Overwriting service %s" % service_name)
	_services[service_name] = service_node

## Gets a service. If it doesn't exist, throws an error (helps catch bugs at load time)
func get_service(service_name: StringName) -> Node:
	assert(_services.has(service_name), "ServiceLocator: Critical error! Service %s is not registered!" % service_name)
	return _services[service_name]

## Removes a service
func unregister_service(service_name: StringName) -> void:
	_services.erase(service_name)
