## Virtual class for all states
## (enter, exit, update, physics_update)
## overridden by child states
@abstract
class_name State
extends Node

signal play_audio(sound: AudioStreamWAV)
signal transitioned()

var parent

## Virtual function
## Called upon state entering StateMachine
@abstract
func enter() -> void

## Virtual function
## Called upon state exiting State Machine
@abstract
func exit() -> void

## Virtual function
## Called within _process
## var delta: delta from _process
@abstract
func update(delta) -> void

## Virtual function
## Called within _physics_process
## var delta: delta from _physics_process
@abstract
func physics_update(delta) -> void

## Virtual function
## Called for pathfinding states
@abstract
func target_reached() -> void
