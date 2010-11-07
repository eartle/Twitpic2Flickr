# Description
I wanted to transfer my photos from Twitpic to Flickr.  I found [Twitpickr](http://twitpickr.wijndaele.com/), but was disappointed that it only tried to upload your last 20 photos and it didn't preserve the Twitpic message as the photo title on Flickr.

I created this ruby script to upload *all* your photos from Twitpic to Flickr in *chronological order* using the *Twitpic message as the Flickr title*.

Any questions, I am [@eartle](http://twitter.com/#!/eartle) on Twitter.

# Usage
Run Twitpic2Flickr.rb with your Twitter username as an argument.  You will be asked to authenticate against Flickr the first time you run (You probably don't want to run a second time, if it worked, as it will just upload all your images again). 

Example:

<code>
ruby Twitpic2Flickr.rb eartle
</code>

# Notes
This project uses rflickr and mime-types through ruby-gems.

