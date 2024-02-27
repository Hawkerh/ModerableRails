# spec/moderable_spec.rb

require 'spec_helper'
require 'rails/all'
require_relative '../lib/Moderable' # Assurez-vous de spécifier le chemin correct

RSpec.describe Moderable do
  class ModerableTest
    include Moderable
    attr_accessor :is_accepted
  end

  # Test de is_acceptable?
  describe 'is_acceptable?' do
    let(:moderable) { ModerableTest.new }

    it 'returns true if the text is acceptable' do
      expect(moderable.is_acceptable?("Bonjour, comment ça va?")).to eq(true)
    end

    it 'returns false if the text is not acceptable' do
      expect(moderable.is_acceptable?("Ferme ta gueule")).to eq(false)
    end
  end

    # Test initialisation sans texte
  describe 'Initialization without text' do
    let(:moderable) { ModerableTest.new }

    it 'initializes without text' do
      expect(moderable.txt_to_check).to eq([])
    end
  end



  # Test initialisation avec un seul texte
  describe 'Initialization with a single text' do
    let(:text) { "imbecile" }
    let(:moderable) { ModerableTest.new(text) }

    it 'initializes with a single text' do
      expect(moderable.txt_to_check.map(&:content)).to eq([text])
    end
  end

  # Test initialisation avec des textes multiples
  describe 'Initialization with multiple texts' do
    let(:texts) { ["Ferme ta gueule", "Bonjour, comment ça va?"] }
    let(:moderable) { ModerableTest.new(*texts) }

    it 'initializes with multiple texts' do
      expect(moderable.txt_to_check.map(&:content)).to eq(texts)
    end
  end

  # Test de la logique de modération
  describe 'Moderation logic' do
    let(:texts) { ["Ferme ta gueule", "Bonjour, comment ça va?"] }
    let(:moderable) { ModerableTest.new(*texts) }

    it 'moderates texts' do
      expect(moderable.is_accepted).to eq([{ text: "Ferme ta gueule", acceptable: false }, { text: "Bonjour, comment ça va?", acceptable: true }])
    end
  end

   # Test de la détection et du traitement des changements de contenu
  describe 'Content change detection and handling' do
    let(:texts) { ["Ferme ta gueule", "Bonjour, comment ça va?"] }
    let(:moderable) { ModerableTest.new(*texts) }

    it 'detects and handles content changes' do
      moderable.txt_to_check[0].content = "s'il te plaît"
      expect(moderable.is_accepted).to eq([{ text: "s'il te plaît", acceptable: true }, { text: "Bonjour, comment ça va?", acceptable: true }])
    end
  end



 end
