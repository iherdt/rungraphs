require 'rails_helper'

# http://www.rubydoc.info/github/jnicklas/capybara#The_DSL
# http://railscasts.com/episodes/257-request-specs-and-capybara

# example

# feature "the signup process" do

#   scenario "has a new user page" do
#     visit new_user_url
#     expect(page).to have_content "New user"
#   end

#   feature "signing up a user" do
#     before(:each) do
#       visit new_user_url
#       fill_in 'username', :with => "testing_username"
#       fill_in 'password', :with => "biscuits"
#       click_on "Create User"
#     end

#     scenario "redirects to team index page after signup" do
#       expect(page).to have_content "Team Index Page"
#     end

#     scenario "shows username on the homepage after signup" do
#       expect(page).to have_content "testing_username"
#     end
#   end

# end

# Important Methods

# Visiting a page
# visit('/projects')
# visit(post_comments_path(post))
# Clicking
# click_link('id-of-link')
# click_link('Link Text')
# click_button('Save')
# click_on('Link Text') # clicks on either links or buttons
# click_on('Button Value')
# Forms
# fill_in('id-of-input', :with => 'whatever you want')
# fill_in('Password', :with => 'Seekrit')
# fill_in('Description', :with => 'Really Long Text...')
# choose('A Radio Button')
# check('A Checkbox')
# uncheck('A Checkbox')
# attach_file('Image', '/path/to/image.jpg')
# select('Option', :from => 'Select Box')
# Content (page)
# expect(page).to have_content('Blah blah blah')