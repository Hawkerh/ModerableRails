# frozen_string_literal: true

require_relative "Moderable/version"
require 'active_support'
require 'net/http'
require 'uri'
require 'json'
require 'observer'

module Moderable
  extend ActiveSupport::Concern

  class ModText
    include Observable

    attr_reader :content, :index

    def initialize(content, index)
      @content = content
      @index = index
    end

    def content=(new_content)
      @content = new_content
      changed
      notify_observers(self)
    end
  end

  included do
    attr_reader :txt_to_check, :is_accepted

    @moderation_rate = 0.91

    def initialize(*texts)
      @txt_to_check = texts.each_with_index.map { |text, index| ModText.new(text, index) }
      @is_accepted = []
      add_observers_to_mod_texts
      moderate_texts
    end

    def self.moderation_rate
      @moderation_rate
    end

    def self.moderation_rate=(value)
      @moderation_rate = value
    end

    def is_acceptable?(str)
      uri = URI("https://moderation.logora.fr/predict?text=#{URI.encode_www_form_component(str)}&language=fr-FR")
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      result['prediction']['0'] < self.class.moderation_rate
    end

    private

    def moderate_texts
      @txt_to_check.each { |mod_text| @is_accepted[mod_text.index] = { text: mod_text.content, acceptable: is_acceptable?(mod_text.content) } }
    end

    def add_observers_to_mod_texts
      observer = proc { |mod_text| observer_logic(mod_text) }
      @txt_to_check.each { |modtext| modtext.add_observer(observer, :call) }
    end

    def observer_logic(mod_text)
      @is_accepted[mod_text.index] = { text: mod_text.content, acceptable: is_acceptable?(mod_text.content) }
    end

  end
end
