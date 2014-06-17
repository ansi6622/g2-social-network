require 'spec_helper'

feature "Users interact with site" do

  before do
    ActionMailer::Base.deliveries.clear
    @ellie = create_user(
      first_name: 'Ellie',
      last_name: 'S',
      email: 'elli@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )
  end

  scenario "user can view all users" do

    seth = create_user(
      first_name: 'Seth',
      last_name: 'M',
      email: 'seth@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    bebe = create_user(
      first_name: 'Bebe',
      last_name: 'Peng',
      email: 'bebe@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    visit '/'
    click_on 'Login'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'

    expect(page).to have_content "Bebe Peng"
    expect(page).to have_content "Add Friend"
    expect(page).to have_content "Seth M"
    expect(page).to have_content "Add Friend"
  end

  scenario "only logged in users can view all users" do
    visit '/users'
    expect(page).to have_content "Please login"
  end


  scenario "user can request to add a friend and that friend can confirm" do
    seth = create_user(
      first_name: 'Seth',
      last_name: 'M',
      email: 'seth@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )
    visit '/'
    click_on 'Login'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'

    within('.non_friend_container') do
      expect(page).to have_content 'Seth M'
      expect(page).to have_content 'Add Friend'
    end

    expect(ActionMailer::Base.deliveries.length).to eq 0

    within '.non_friend_container' do
      page.first(:button, 'Add Friend').click
    end

    expect(ActionMailer::Base.deliveries.length).to eq 1

    expect(page).to have_content 'Friendship request sent'

    within('.non_friend_container') do
      expect(page).to have_content 'Seth M'
      expect(page).to have_content 'Pending'
    end

    click_on 'Logout'
    click_on 'Login'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'

    visit "/confirm-friendships/#{seth.id}/#{@ellie.id}"

    within('.friend_container') do
      expect(page).to have_text('Ellie S')
      expect(page).to have_button('Unfriend')
    end

    click_on 'Logout'
    click_on 'Login'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'

    within('.friend_container') do
      expect(page).to have_text('Seth M')
      expect(page).to have_button('Unfriend')
    end
  end

  scenario "user can remove a friend" do

    seth = create_user(
      first_name: 'Seth',
      last_name: 'M',
      email: 'seth@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    graph = Graph.new
    graph.add_friendship(@ellie.id, seth.id)
    graph.confirm_friendship(@ellie.id, seth.id)

    visit '/'
    click_on 'Login'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'

    within '.friend_container' do
      expect(page).to have_content 'Seth M'
      page.first(:button, 'Unfriend').click
    end
    expect(page).to have_content 'Friend removed'
    within '.non_friend_container' do
      expect(page).to have_content 'Seth M'
      expect(page).to have_content 'Add Friend'
    end

    within '.friend_container' do
      expect(page).to have_no_content 'Seth M'
    end
  end

  scenario "user can see photos of all friends" do
    seth = create_user(
      first_name: 'Seth',
      last_name: 'M',
      email: 'seth@example.com',
      confirmation: true
    )

    visit '/'
    click_on 'Login'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'
    click_link 'elli@example.com'
    attach_file('Profile pic', Rails.root.join('spec/images/unicorn_cat.jpg'))
    click_on 'Upload Picture'
    click_on 'Logout'
    click_on 'Login'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'
    expect(page).to have_css('img', visible: 'unicorn_cat.jpg')
  end

  scenario 'User can see friends in the left hand column and users they are not friends with on the right' do
    bebe = create_user(
      first_name: 'Bebe',
      last_name: 'Peng',
      email: 'bebe@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    seth = create_user(
      first_name: 'Seth',
      last_name: 'M',
      email: 'seth@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    visit '/'
    click_on 'Login'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'

    graph = Graph.new
    graph.add_friendship(seth.id, bebe.id)
    graph.confirm_friendship(seth.id, bebe.id)

    visit page.current_path

    within '.friend_container' do
      expect(page).to have_content('Bebe Peng')
    end

    within '.non_friend_container' do
      expect(page).to have_content('Ellie S')
    end

  end

  scenario 'a user can view their own posts and the posts of users they are friends with' do
    seth = create_user(
      first_name: 'Seth',
      last_name: 'M',
      email: 'seth@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    bebe = create_user(
      first_name: 'Bebe',
      last_name: 'Peng',
      email: 'bebe@example.com',
      password: 'hello12345',
      password_confirmation: 'hello12345',
      confirmation: true
    )

    graph = Graph.new
    graph.add_friendship(seth.id, bebe.id)
    graph.confirm_friendship(seth.id, bebe.id)

    visit '/'
    click_on 'Login'
    fill_in 'Email', with: 'seth@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'
    click_on 'seth@example.com'
    fill_in 'post[post_body]', with: 'hello'
    click_on 'Post'
    click_on 'Logout'

    click_on 'Login'
    fill_in 'Email', with: 'elli@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'
    click_on 'elli@example.com'
    fill_in 'post[post_body]', with: 'goodbye'
    click_on 'Post'
    click_on 'Logout'

    click_on 'Login'
    fill_in 'Email', with: 'bebe@example.com'
    fill_in 'Password', with: 'hello12345'
    click_button 'Login'
    click_on 'bebe@example.com'
    fill_in 'post[post_body]', with: 'cya later'
    click_on 'Post'
    expect(page).to have_content 'hello'
    expect(page).to have_content 'cya later'
    expect(page).to_not have_content 'goodbye'
  end
end