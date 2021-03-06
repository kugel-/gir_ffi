# frozen_string_literal: true
require 'gir_ffi_test_helper'

# Tests generated methods and functions in the GTop namespace. This namespace
# contains types with bad names, like 'glibtop_cpu'.
describe 'The generated GTop module' do
  before do
    begin
      GirFFI.setup :GTop
    rescue
      skip 'No GIR data for GTop available'
    end
  end

  describe 'Glibtop' do
    it 'is a valid struct class' do
      GTop::Glibtop.ancestors.must_include GirFFI::StructBase
    end

    it 'can be created using Glibtop.init' do
      skip unless get_method_introspection_data 'GTop', 'glibtop', 'init'
      instance = GTop::Glibtop.init
      instance.must_be_kind_of GTop::Glibtop
    end
  end
end
