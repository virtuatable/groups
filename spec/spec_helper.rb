require 'bundler'
Bundler.require :test

service = Arkaan::Utils::MicroService.instance
  .register_as('groups')
  .from_location(__FILE__)
  .in_test_mode