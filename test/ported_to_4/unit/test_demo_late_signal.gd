extends GutTest

class TimedSignaler:
	extends Node

	signal the_signal

	var _timer = null

	func _ready():
		_timer = Timer.new()
		add_child(_timer)
		_timer.connect('timeout',Callable(self,'_on_timer_timeout'))
		_timer.one_shot = true

	func _on_timer_timeout():
		print('TimedSignaler: emitting the_signal ', Time.get_ticks_msec())
		emit_signal('the_signal')
		print('TimedSignaler: emitted the_signal ', Time.get_ticks_msec())

	func emit_after(time):
		_timer.set_wait_time(time)
		_timer.start()


func test_demo():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	signaler.emit_after(.5)
	print('test_demo: signaler created ', Time.get_ticks_msec())

	yield_to(signaler, 'the_signal', 10)
	print("test_demo: Signaler Connections:")
	print("  ", "\n  ".join(signaler.the_signal.get_connections()))
	print('test_demo: after connecting to signals ', Time.get_ticks_msec())

	await gut.timeout
	pass_test('example')
	print('test_demo: end of test ', Time.get_ticks_msec())
