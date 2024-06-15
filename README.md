# README

A working example of how to run capybara tests with cuprite and browserless v2

# How to use this

## For interactive testing

    make setup_test # only once

    make guard

    # in another terminal/editor
    vi spec/system/home_spec.rb

    # open browserless debugger [http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN](http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN)
    # click on sessions

    # do changes and save the file

# URLs

* rails server [http://localhost:3000](http://localhost:3000)
* browserless built-in documentation [http://localhost:3333/docs](http://localhost:3333/docs)
* browserless debugger [http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN](http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN)
* browserless documenation [https://docs.browserless.io/](https://docs.browserless.io/)

# References of the setup

* [marsbased article](https://marsbased.com/blog/2022/04/18/cuprite-driver-capybara-sample-implementation)
* [the evilmartials original article](https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing#hire-us)
