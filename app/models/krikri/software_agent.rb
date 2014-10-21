module Krikri
  ##
  # SoftwareAgent is a mixin for logic common to code that generates a
  # Krikri::Activity.
  #
  # TODO: Figure out what, if anything, agents need to know about
  #   themselves. They will likely have names or versions or some such.
  #   If not, remove this module.
  module SoftwareAgent
    extend ActiveSupport::Concern
  end
end
