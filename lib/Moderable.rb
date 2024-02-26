# frozen_string_literal: true

require_relative "Moderable/version"
require 'active_support'
require 'net/http'
require 'uri'
require 'json'
require 'observer'

module Moderable
  extend ActiveSupport::Concern

  # ModText est une classe qui permet de stocker un texte et son index pour faciliter la gestion des observateurs
  class ModText
    include Observable

    attr_reader :content, :index

    def initialize(content, index)
      @content = content
      @index = index
    end

    # Permet de modifier le contenu du texte et de notifier les observateurs
    def content=(new_content)
      @content = new_content
      changed
      notify_observers(self)
    end
  end

  included do

    #@moderation_rate est un attribut de classe qui permet de définir le taux de modération accepté
    #@txt_to_check est un tableau de ModText qui contient les textes à modérer
    attr_reader :txt_to_check, :is_accepted

    # Par défaut, le taux de modération est de 0.91
    @moderation_rate = 0.91

    # @param texts [Array<String>] les textes à modérer
    def initialize(*texts)
      @txt_to_check = texts.each_with_index.map { |text, index| ModText.new(text, index) }
      @is_accepted = []
      add_observers_to_mod_texts
      moderate_texts
    end

    def self.moderation_rate
      @moderation_rate
    end

    # @param value [Float] le taux de modération accepté
    def self.moderation_rate=(value)
      @moderation_rate = value
    end

    # @param str [String] le texte à modérer
    # @return [Boolean] true si le texte est acceptable, false sinon
    # Cette méthode envoie le texte à l'API de modération et retourne true si le texte est acceptable, false sinon
    def is_acceptable?(str)
      uri = URI("https://moderation.logora.fr/predict?text=#{URI.encode_www_form_component(str)}&language=fr-FR")
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      result['prediction']['0'] < self.class.moderation_rate
    end

    private

    # Cette méthode modère les textes et stocke le résultat dans l'attribut @is_accepted
    def moderate_texts
      @txt_to_check.each { |mod_text| @is_accepted[mod_text.index] = { text: mod_text.content, acceptable: is_acceptable?(mod_text.content) } }
    end

    # Cette méthode ajoute un observateur à chaque ModText
    def add_observers_to_mod_texts
      observer = proc { |mod_text| observer_logic(mod_text) }
      @txt_to_check.each { |modtext| modtext.add_observer(observer, :call) }
    end

    # Cette méthode est definie dans le bloc de code passé à add_observer
    def observer_logic(mod_text)
      @is_accepted[mod_text.index] = { text: mod_text.content, acceptable: is_acceptable?(mod_text.content) }
    end

  end
end
