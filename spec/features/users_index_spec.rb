require 'spec_helper'

feature "Users interact with site" do
  before :each do
    visit ('/')
    click_on 'Register'
    fill_in 'First name', with: 'Bebe'
    fill_in 'Last name', with: 'Peng'
    fill_in 'Email', with: 'bebe@example.com'
    fill_in 'Password', with: 'hello12345'
    fill_in 'Confirm password', with: 'hello12345'

    click_on 'Create an Account'
    expect(page).to have_content "Welcome bebe@example.com"
    expect(page).to_not have_content "Register"
    expect(page).to_not have_content "Login"
  end
  scenario "user can view all users" do
    click_on 'Logout'
    visit '/'
    click_on 'Register'
    fill_in 'First name', with: 'Seth'
    fill_in 'Last name', with: 'M'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    fill_in 'Confirm password', with: 'hello12345'
    click_on 'Create an Account'
    click_on 'Logout'

    visit '/'
    click_on 'Register'
    fill_in 'First name', with: 'Ellie'
    fill_in 'Last name', with: 'S'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    fill_in 'Confirm password', with: 'hello12345'
    click_on 'Create an Account'

    expect(page).to have_content "Bebe Peng"
    expect(page).to have_content "Seth M"
  end

  scenario "user can add a friend" do
    click_on 'Logout'
    visit '/'
    click_on 'Register'
    fill_in 'First name', with: 'Seth'
    fill_in 'Last name', with: 'M'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    fill_in 'Confirm password', with: 'hello12345'
    click_on 'Create an Account'
    expect(page).to_not have_content 'Unfriend'

    within '.body_container' do
      page.first(:button, 'Add Friend').click
    end

    expect(page).to have_content 'Friend added'
    expect(page).to have_content 'Unfriend'
  end

  scenario "user can remove a friend" do
    click_on 'Logout'
    visit '/'
    click_on 'Register'
    fill_in 'First name', with: 'Seth'
    fill_in 'Last name', with: 'M'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    fill_in 'Confirm password', with: 'hello12345'
    click_on 'Create an Account'
    expect(page).to_not have_content 'Unfriend'

    within '.body_container' do
      page.first(:button, 'Add Friend').click
      end
    within '.body_container' do
      page.first(:button, 'Unfriend').click
    end
    expect(page).to have_content 'Friend removed'
    expect(page).to have_content 'Add Friend'
    expect(page).to_not have_content 'Unfriend'
  end
end