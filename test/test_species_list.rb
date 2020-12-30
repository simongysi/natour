#!/usr/bin/env ruby
require 'minitest/autorun'
require 'natour'

class TestSpeciesList < Minitest::Test
  include Minitest
  include Natour

  def test_load_file_unknown_format
    filename = "#{__dir__}/data/2020-06-01 171703.gpx"
    species_lists = SpeciesList.load_file(filename)
    assert_equal(0, species_lists.count)
  end

  def test_load_file_kosmos_vogelfuehrer
    filename = "#{__dir__}/data/kosmos_vogelfuehrer.csv"
    species_lists = SpeciesList.load_file(filename)
    assert_equal(1, species_lists.count)

    species_list = species_lists.first
    assert_equal(filename, species_list.path)
    assert_nil(species_list.date)
    assert_equal(:kosmos_vogelfuehrer, species_list.type)
    assert_nil(species_list.name)
    assert_nil(species_list.description)
    assert_equal(4, species_list.count)
    assert_equal([
      Species.new('Garrulus glandarius', 'Eichelhäher'),
      Species.new('Cygnus olor', 'Höckerschwan'),
      Species.new('Aegithalos caudatus', 'Schwanzmeise'),
      Species.new('Columba livia "domestica"', 'Straßentaube')
    ], species_list.to_a)
  end

  def test_load_file_flora_helvetica
    filename = "#{__dir__}/data/flora_helvetica_sammlungen.csv"
    species_lists = SpeciesList.load_file(filename)
    assert_equal(1, species_lists.count)

    species_list = species_lists.first
    assert_equal(filename, species_list.path)
    assert_nil(species_list.date)
    assert_equal(:flora_helvetica, species_list.type)
    assert_nil(species_list.name)
    assert_nil(species_list.description)
    assert_equal(3, species_list.count)
    assert_equal([
      Species.new('Abies alba', 'Tanne'),
      Species.new('Empetrum nigrum subsp. hermaphroditum', 'Zwittrige Krähenbeere'),
      Species.new('Galium mollugo aggr.', 'Wiesen-Labkraut')
    ], species_list.to_a)
  end

  def test_load_file_flora_helvetica_multi
    filename = "#{__dir__}/data/flora_helvetica_sammlungen_multi.csv"
    species_lists = SpeciesList.load_file(filename)
    assert_equal(3, species_lists.count)

    species_list = species_lists[0]
    assert_equal(filename, species_list.path)
    assert_equal(:flora_helvetica, species_list.type)
    assert_nil(species_list.date)
    assert_equal('Favoriten', species_list.name)
    assert_nil(species_list.description)
    assert_equal(3, species_list.count)
    assert_equal([
      Species.new('Crepis aurea', 'Gold-Pippau'),
      Species.new('Crepis biennis', 'Wiesen-Pippau'),
      Species.new('Crepis capillaris', 'Kleinköpfiger Pippau')
    ], species_list.to_a)

    species_list2 = species_lists[1]
    assert_equal(filename, species_list2.path)
    assert_equal(:flora_helvetica, species_list2.type)
    assert_equal(Date.new(2020, 6, 27), species_list2.date)
    assert_equal('Gräserkurs', species_list2.name)
    assert_equal('Vertiefung Poaceae', species_list2.description)
    assert_equal(3, species_list2.count)
    assert_equal([
      Species.new('Briza media', 'Mittleres Zittergras'),
      Species.new('Deschampsia cespitosa', 'Rasen-Schmiele'),
      Species.new('Festuca rubra', 'Rot-Schwingel')
    ], species_list2.to_a)

    species_list3 = species_lists[2]
    assert_equal(filename, species_list3.path)
    assert_equal(:flora_helvetica, species_list3.type)
    assert_equal(Date.new(2020, 6, 26), species_list3.date)
    assert_equal('Gräserkurs', species_list3.name)
    assert_equal('Vertiefung Cyperaceae', species_list3.description)
    assert_equal(3, species_list3.count)
    assert_equal([
      Species.new('Carex flava', 'Gewöhnliche Gelbe Segge'),
      Species.new('Carex leporina', 'Hasenpfoten-Segge'),
      Species.new('Carex ornithopoda', 'Vogelfuss-Segge')
    ], species_list3.to_a)
  end

  def test_load_file_info_flora
    filename = "#{__dir__}/data/obs_export_2020-07-26_22h04.csv"
    species_lists = SpeciesList.load_file(filename)
    assert_equal(1, species_lists.count)

    species_list = species_lists.first
    assert_equal(filename, species_list.path)
    assert_nil(species_list.date)
    assert_equal(:info_flora, species_list.type)
    assert_nil(species_list.name)
    assert_nil(species_list.description)
    assert_equal(3, species_list.count)
    assert_equal([
      Species.new('Anagallis arvensis', nil),
      Species.new('Daphne laureola', nil),
      Species.new('Primula veris', nil)
    ], species_list.to_a)
  end

  def test_load_file_info_flora_with_duplicates
    filename = "#{__dir__}/data/obs_export_2020-08-30_20h31.csv"
    species_lists = SpeciesList.load_file(filename)
    assert_equal(1, species_lists.count)

    species_list = species_lists.first
    assert_equal(filename, species_list.path)
    assert_nil(species_list.date)
    assert_equal(:info_flora, species_list.type)
    assert_nil(species_list.name)
    assert_nil(species_list.description)
    assert_equal(5, species_list.count)
    assert_equal([
      Species.new('Hypochaeris uniflora', nil),
      Species.new('Juncus jacquinii', nil),
      Species.new('Juncus trifidus', nil),
      Species.new('Juncus triglumis', nil),
      Species.new('Ligusticum mutellinoides', nil)
    ], species_list.to_a)
  end
end
