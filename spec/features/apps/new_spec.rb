require 'rails_helper'

RSpec.describe 'new application' do
    before :each do
        @shelter = Shelter.create!(name: "Craig's Raccoon Emporium", rank: 1, city: "Omaha")
        @pet_1 = @shelter.pets.create!(name: "Pope Francis Bacon", age: 14)
        visit "/shelters/#{@shelter.id}"
        click_on "Begin a new application"
    end

    it 'has a form to create a new application' do
        expect(page).to have_field('Name')
        expect(page).to have_field('Street Address')
        expect(page).to have_field('City')
        expect(page).to have_field('Zip Code')
    end

    it 'user story 2 can start an application' do
        expect(current_path).to eq("/shelters/#{@shelter.id}/apps/new")
        # When I fill in this form with my:
        fill_in('Name', with: 'Gob Beldof')
        fill_in('Street Address', with: '123 Sesame St')
        fill_in('City', with: 'Omaha, NE')
        fill_in('Zip Code', with: '45678')
        click_on("Submit")
        @app = App.find_by( name:"Gob Beldof")
        # Then I am taken to the new application's show page
        expect(current_path).to eq("/apps/#{@app.id}")
        # And I see my Name, address information, description of why I would make a good home
        expect(page).to have_content('Gob Beldof')
        expect(page).to have_content('123 Sesame St')
        # And I e an indicator that this application is "In Progress"
        expect(page).to have_content('In Progress')
    end

    it 'displays error for incomplete form' do
        fill_in('Street Address', with: '123 Sesame St')
        fill_in('City', with: 'Omaha')
        fill_in('Zip Code', with: '45678')
        click_on("Submit")

        expect(page).to have_content("Name can't be blank")
    end

end