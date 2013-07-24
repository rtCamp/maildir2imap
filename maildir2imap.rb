mail_dir=ARGV[0]
imap_host=ARGV[1]
imap_user=ARGV[2]
imap_pass=ARGV[3]
imap_dir=ARGV[4]

require 'maildir'
require 'net/imap'
require 'time'
#Create object
puts  "maildir"
maildir = Maildir.new(mail_dir, false); #avoid creating new maildir if not exist
#maildir.serializer = Maildir::Serializer::Mail.new
puts "before IMAP"
imap = Net::IMAP.new('imap.gmail.com',993,true)
puts "before auth"
puts imap.login(imap_user, imap_pass)
puts "auth done"
puts imap.examine(imap_dir)
maildir.list(:new).each do |singlemail|
	puts maildir.list(:new).first.data
	date = singlemail.data.scan(/Delivery-date:(.*[^-a-zA-Z1-9_.])?/i)
	puts date
	puts "DATE IS HERE"
	#puts mail.date.to_s
	puts "add message\r\n"
	#ctime =  Time.parse(mail.date.to_s)
	ctime = Time.parse(date.to_s)
	puts ctime
 	imap.append(imap_dir,singlemail.data,nil,ctime)
	puts "mesage added"
end
puts "done"