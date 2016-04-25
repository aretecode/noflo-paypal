# 0.0.3
* ConfigurePaypal client object insteadof each component configuring with apikeys & calling library

# 0.0.4
* Refactoring CreateCharge & Subscription to move responsibility to the client instead of the component
* Fixing ConfigurePaypal error return
* Using noflo 7.3

# 0.0.5
* Loading spec with the Tester instead of requiring
* Using noflo 7.4

# 0.0.6
* Using `noflo-tester` 0.3
* Hacking `noflo-tester` to not load `cache`
* Loading Components in `spec/` with strings insteadof requiring component file in the test
* Fixing `ConfigurePaypal` variable `data`
* Adding `ConfigurePaypal` other configuration keys
* Remove old stuff fromm readme

# 0.0.7
* Adding description to CreateCharge transaction
* Adding FakeExecuteTest for mock testing

# 0.0.8
* Change all case to camel-style PayPal
