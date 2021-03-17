#Sinatra Flatiron Project - Mod2

##General Information

There are many things I love about my career in sales. It's fast paced. I love the thrill of finding new customers, uncovering new opportunites, and the competitive nature of it. 

Standing in the way of the enjoyable aspects are some administrative tasks. In order to generate proposals and responses to RFP's and bids for customers I find that I spend far too much time formatting, editing, and tweaking documents. This project is an effort to make these tedious and error prone processes fast, repeatable, and bulletproof. 

##Technologies 
* Sinatra
* Carrierwave
* CSV
* bcrypt
* rake-flash'

##Setup

To run this program, navigate to the root of the directory. run 'bundle install' and then start your server by running 'shotgun' in the terminal.

In your web browser go to 'localhost:9393.' You will be prompted to create an account.

You will be routed to a screen showing 10 accounts that were automatically seeded into your database. You can use CRUD functionality to build proposals. Validations will guide you, but you will select different options for your proposal and then have the option to preview what you've created. You'll notice many dynamic features about the preview page, which are the end goal of the project:

* photos - each proposal needs a photo of the exact machine configuration that you've selected. Carrierwave helped accomplish this. If no machine is found, the user has the option to upload an image. The next time around the application will recognize that same configuration and show the photo.
* accessories, equipment options, service options, pricing, etc. is dynamic. There is no need for changes after you've edited the proposal to your liking.
* styling - this is dynamic as well. Different sections on the page are automatically styled to fit nicely on the preview





