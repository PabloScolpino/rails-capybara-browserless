# README

A wannabe working example of how to run capybara tests with cuprite and browserless

Currently an example for Ferrum development

# How to use this

## To run tests and see the error

    make build setup_test test

## For interactive testing

    make setup_test # only once

    make guard

    # in another terminal/editor
    vi spec/system/home_spec.rb

    # do changes and save the file


# Expected error

```shell
  1) HomeController #index sees the rails logo
     Got 0 failures and 4 other errors:

     1.1) Failure/Error: visit '/'

          JSON::ParserError:
            unexpected token at 'Bad or missing authentication.
            '
          # /bundler/ruby/3.2.0/gems/json-2.7.2/lib/json/common.rb:220:in `parse'
          # /bundler/ruby/3.2.0/gems/json-2.7.2/lib/json/common.rb:220:in `parse'
          # /bundler/ruby/3.2.0/gems/ferrum-0.14/lib/ferrum/browser/process.rb:67:in `initialize'
          # /bundler/ruby/3.2.0/gems/ferrum-0.14/lib/ferrum/browser/process.rb:27:in `new'
          # /bundler/ruby/3.2.0/gems/ferrum-0.14/lib/ferrum/browser/process.rb:27:in `start'
          # /bundler/ruby/3.2.0/gems/ferrum-0.14/lib/ferrum/browser.rb:275:in `start'
          # /bundler/ruby/3.2.0/gems/ferrum-0.14/lib/ferrum/browser.rb:131:in `initialize'
          # /bundler/ruby/3.2.0/gems/cuprite-0.15/lib/capybara/cuprite/browser.rb:24:in `initialize'
          # /bundler/ruby/3.2.0/gems/cuprite-0.15/lib/capybara/cuprite/driver.rb:47:in `new'
          # /bundler/ruby/3.2.0/gems/cuprite-0.15/lib/capybara/cuprite/driver.rb:47:in `browser'
          # /bundler/ruby/3.2.0/gems/cuprite-0.15/lib/capybara/cuprite/driver.rb:52:in `visit'
          # /bundler/ruby/3.2.0/gems/capybara-3.40.0/lib/capybara/session.rb:281:in `visit'
          # /bundler/ruby/3.2.0/gems/capybara-3.40.0/lib/capybara/dsl.rb:52:in `call'
          # /bundler/ruby/3.2.0/gems/capybara-3.40.0/lib/capybara/dsl.rb:52:in `visit'
          # ./spec/system/home_spec.rb:8:in `block (3 levels) in <top (required)>'
          # ./spec/system/support/better_rails_system_tests.rb:31:in `block (2 levels) in <main>'
```

# URLs

* rails server [http://localhost:3000](http://localhost:3000)
* browserless built-in documentation [http://localhost:3333/docs](http://localhost:3333/docs)
* browserless debugger [http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN](http://localhost:3333/debugger?token=CHROMIUMTESTTOKEN)
* browserless documenation [https://docs.browserless.io/](https://docs.browserless.io/)
