require 'rails_helper'

RSpec.describe 'Application show page' do
  before :each do
    @shelter = Shelter.create!(name: "Craig's Raccoon Emporium", rank: 1, city: "Omaha, NE")
    @other_shelter = Shelter.create!(name: "Ding Dong's Coon Ditch", rank: 1, city: "Omaha, NE")

    @pet_1 = @shelter.pets.create!(name: "King Trash Mouth", age: 14)
    @pet_2 = @shelter.pets.create!(name: "Princess Dumptruck", age: 18)
    @pet_3 = @shelter.pets.create!(name: "Eggs Sinclair", age: 10)
    @pet_4 = @other_shelter.pets.create!(name: "Monster Truck Wendy", age: 5)

    @app = @shelter.apps.create!(
      name: "Gob Beldof", 
      address: "152 Animal Ave.", 
      city: "Omaha, NE", 
      zip_code: "19593",
      status: "In Progress"
    )
  end

  it 'displays the attributes of the selected application' do
    # @app.pets << @pet_2
    # @app.pets << @pet_3
    visit "apps/#{@app.id}"
    expect(page).to have_content(@app.name)
    expect(page).to have_content(@app.address)
    expect(page).to have_content(@app.city)
    expect(page).to have_content(@app.zip_code)
    # expect(page).to have_link(@pet_2.name)
    # expect(page).to have_link(@pet_3.name)
    expect(page).to_not have_link(@pet_1.name)
    expect(page).to_not have_link(@pet_4.name)
    expect(page).to have_content(@app.status)
  end

  describe 'if the application has not been submitted' do
    it 'shows a field to search for adoptable pets' do
      
      visit "apps/#{@app.id}"
      expect(page).to have_content("In Progress")

      expect(page).to have_content("Add a Pet to this Application")
      expect(page).to have_field("Search")

      fill_in("Search", with: "#{@pet_1.name}")
      click_on("Submit")

      expect(current_path).to eq("/apps/#{@app.id}")
      expect(page).to have_content(@pet_1.name)
    end
    
    it 'ignores case and finds partial matches' do
      visit "apps/#{@app.id}"
      fill_in("Search", with: "king")
      click_on("Submit")
      expect(page).to have_content(@pet_1.name)

      fill_in("Search", with: "wend")
      click_on("Submit")
      expect(page).to have_content(@pet_4.name)
    end

    it 'shows a list of all pets currently interested in adopting' do
      @app.pets << @pet_2
      @app.pets << @pet_3
      visit "apps/#{@app.id}"
      within("#pets_wanted") do
        @app.pets.each do |pet|
          expect(page).to have_content(pet.name)
          expect(page).to have_content(pet.shelter.name)
        end
        expect(page).to_not have_content(@pet_1.name)
        expect(page).to_not have_content(@pet_4.name)
        expect(page).to_not have_content(@pet_4.shelter.name)
      end
      
    end

    it 'can add pets' do
      visit "apps/#{@app.id}"
      fill_in("Search", with: "#{@pet_1.name}")
      click_on("Submit")
      within("#pet_#{@pet_1.id}") do
        click_on("Adopt this pet")
      end
      expect(current_path).to eq("/apps/#{@app.id}")
      expect(@app.pets).to include(@pet_1)
    end

    it 'does not show an option to submit if no pets added' do
      visit "apps/#{@app.id}"
      expect(page).to_not have_button("Submit Application")

    end

    it 'can submit an application' do
      @app.pets << @pet_2
      @app.pets << @pet_3
      visit "apps/#{@app.id}"
      expect(page).to have_field("Description")
      expect(page).to have_button("Submit Application")
      fill_in("Description", with: "Because Racoon Jesus told me to.")
      click_on("Submit Application")
      expect(current_path).to eq("/apps/#{@app.id}")
      expect(page).to have_content("Pending")
      expect(page).to_not have_content("Submit Application")
    end
  end
end