extends SceneTree
var Awaiter = load('res://addons/gut/awaiter.gd')
var SignalWatcher = load('res://addons/gut/signal_watcher.gd')

class Signaler:
	signal the_signal


class TimedSignaler:
	extends Node

	signal the_signal

	var _timer = null

	func _ready():
		_timer = Timer.new()
		add_child(_timer)
		_timer.timeout.connect(_on_timer_timeout)
		_timer.one_shot = true

	func _on_timer_timeout():
		emit_signal('the_signal')

	func emit_after(time):
		_timer.set_wait_time(time)
		_timer.start()


func signal_callback(source):
	print(source, ': ', source.is_connected(signal_callback))



func try_it():
	ts.the_signal.connect(signal_callback.bind(ts.the_signal))
	ts.emit_after(.5)
	await ts.the_signal

var ts = TimedSignaler.new()
func _init():
	get_root().add_child(ts)
	var watcher = SignalWatcher.new()
	watcher.watch_signals(ts)
	await try_it()
	watcher.clear()
	ts.the_signal.disconnect(signal_callback)
	quit()