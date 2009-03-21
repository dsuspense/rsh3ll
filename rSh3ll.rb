#!/usr/bin/env ruby

# Copyright (c) 2006 SilvaSoft, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

#
# author:    http://www.silvasoftinc.com
# author:    Dominic Da Silva (dominic.dasilva@gmail.com)
# version:   2.0
# date:      05/26/2006 

require 'S3'
require 'time' # for httpdate
require 'rexml/document' # for ACL Document manipulation

include REXML

# set your AWS access key and secret access key
AWS_ACCESS_KEY_ID = '<INSERT YOUR AWS ACCESS KEY ID HERE>'
AWS_SECRET_ACCESS_KEY = '<INSERT YOUR AWS SECRET ACCESS KEY HERE>'

if AWS_ACCESS_KEY_ID == '<INSERT YOUR AWS ACCESS KEY ID HERE>' or 
   AWS_SECRET_ACCESS_KEY == '<INSERT YOUR AWS SECRET ACCESS KEY HERE>'
    puts "!!! Update rSh3ll.rb with your AWS credentials !!!"
	puts "!!! You must set your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY !!!"
end

# setting this to false is faster, but your data is not encrypted as it is sent.
USE_SSL = false

# globals
user_ = AWS_ACCESS_KEY_ID
password_ = AWS_SECRET_ACCESS_KEY
host_ = ''
bucket_ = ''

# canned ACLs
CANNED_ACLS = ['private', 'public-read', 'public-read-write', 'authenticated-read']

# print rSh3ll help
def print_help
	puts "bucket [bucketname]"
	puts "count [prefix]"
	puts "createbucket"
	puts "delete <id>"
	puts "deleteall [prefix]"
	puts "deletebucket"
	puts "exit"
	puts "get <id>"
	puts "getacl ['bucket'|'item'] <id>"
	puts "getfile <id> <file>"
	puts "gettorrent <id>"
	puts "head ['bucket'|'item'] <id>"
	puts "host [hostname]"
	puts "list [prefix] [max]"
	puts "listatom [prefix] [max]"
	puts "listrss [prefix] [max]"
	puts "listbuckets"
	puts "pass [password]"
	puts "put <id> <data>"
	puts "putfile <id> <file>"
	puts "putfilewacl <id> <file> ['private'|'public-read'|'public-read-write'|'authenticated-read']"
	puts "quit"
	puts "setacl ['bucket'|'item'] \<id\> ['private'|'public-read'|'public-read-write'|'authenticated-read']"
	puts "user [username]"
end

# begin rSh3ll main

# create AWS connection
conn = S3::AWSAuthConnection.new(user_, password_, USE_SSL)

# print rSh3ll welcome
puts
puts "Welcome to rSh3ll (Amazon S3 command shell for Ruby) (c) 2006 SilvaSoft, Inc."
puts "Type 'help' for command list."
puts

# sets an ACL to public-read
def set_acl_public_read(acl_doc)
      # create Document
      doc = Document.new(acl_doc)

      # get AccessControlList node
      acl_node = XPath.first(doc, '//AccessControlList')

      # delete existing 'AllUsers' Grantee
      acl_node.delete_element "//Grant[descendant::URI[text()='http://acs.amazonaws.com/groups/global/AllUsers']]"

      # create a new READ grant node
      grant_node = Element.new('Grant')
      grantee = Element.new('Grantee')
      grantee.attributes['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
      grantee.attributes['xsi:type'] = 'Group'

      uri = Element.new('URI')
      uri << Text.new('http://acs.amazonaws.com/groups/global/AllUsers')
      grantee.add_element(uri)
      grant_node.add_element(grantee)
      
      perm = Element.new('Permission')
      perm << Text.new('READ')
      grant_node.add_element(perm)

      # attach the new READ grant node
      acl_node.add_element(grant_node)

      return doc.to_s
end

# sets an ACL to private
def set_acl_private(acl_doc)
      # create Document
      doc = Document.new(acl_doc)

      # get AccessControlList node
      acl_node = XPath.first(doc, '//AccessControlList')

      # delete existing 'AllUsers' Grantee
      acl_node.delete_element "//Grant[descendant::URI[text()='http://acs.amazonaws.com/groups/global/AllUsers']]"

      return doc.to_s
end

# sets an ACL to public-read-write
def set_acl_public_read_write(acl_doc)
      # create Document
      doc = Document.new(acl_doc)

      # get AccessControlList node
      acl_node = XPath.first(doc, '//AccessControlList')

      # delete existing 'AllUsers' Grantee
      acl_node.delete_element "//Grant[descendant::URI[text()='http://acs.amazonaws.com/groups/global/AllUsers']]"

      # create a new READ grant node
      grant_node = Element.new('Grant')
      grantee = Element.new('Grantee')
      grantee.attributes['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
      grantee.attributes['xsi:type'] = 'Group'

      uri = Element.new('URI')
      uri << Text.new('http://acs.amazonaws.com/groups/global/AllUsers')
      grantee.add_element(uri)
      grant_node.add_element(grantee)
      
      perm = Element.new('Permission')
      perm << Text.new('READ')
      grant_node.add_element(perm)

      # attach the new grant node
      acl_node.add_element(grant_node)

      # create a new WRITE grant node
      grant_node = Element.new('Grant')
      grantee = Element.new('Grantee')
      grantee.attributes['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
      grantee.attributes['xsi:type'] = 'Group'

      uri = Element.new('URI')
      uri << Text.new('http://acs.amazonaws.com/groups/global/AllUsers')
      grantee.add_element(uri)
      grant_node.add_element(grantee)
      
      perm = Element.new('Permission')
      perm << Text.new('WRITE')
      grant_node.add_element(perm)

      # attach the new grant tree
      acl_node.add_element(grant_node)

      return doc.to_s
end

# loop getting commands
line = ""
begin 
  print "rSh3ll> "	
  # read and split line
  line = STDIN.readline.gsub(/\n/, "")
  tokens = line.split 
  # get command
  command = tokens[0]
  # execute command
  case command
  
    # bucket
    when 'bucket'
      if tokens.size != 2
        puts "error: bucket [bucketname]"
      else 
        bucket_ = tokens[1]
        puts "--- bucket set to '" + bucket_ + "' ---"
      end

    # count      
    when 'count'
      if bucket_ == ''
        puts "error: bucket is not set"
      else 
        puts "--- token count for bucket '" + bucket_ + "' ---"
        puts conn.list_bucket(bucket_).entries.size
      end

    # createbucket
    when 'createbucket'
      response = conn.create_bucket(bucket_).http_response.message
      if response == 'OK'
        puts "--- created bucket '" + bucket_ + "' ---"
      else 
        puts "--- could not created bucket '" + bucket_ + "' ---"
        puts "error: " + response
      end

    # delete
    when 'delete'
      if tokens.size != 2
        puts "error: delete <id>"
      else 
        key = tokens[1]
        response =  conn.delete(bucket_, key).http_response.message      
        if response == 'No Content'
          puts "--- deleted item '" + bucket_ + "/" + key + "' ---"
        else 
          puts "--- could not deleted item '" + bucket_ + "/" + key + "' ---"
          puts "error: " + response
        end
      end
    # deleteall -- TODO: support > 1000 item deletes
    when 'deleteall'
      if bucket_ == ''
        puts "error: bucket is not set"
      else 
        keys = conn.list_bucket(bucket_).entries
        for entry in keys
          item = entry.key
          response =  conn.delete(bucket_, item).http_response.message
          if response == 'No Content'
            puts "--- deleted item '" + bucket_ + "/" + item + "' ---"
          else 
            puts "--- could not deleted item '" + bucket_ + "/" + item + "' ---"
            puts "error: " + response
          end
        end
      end

    # deletebucket
    when 'deletebucket'
      response = conn.delete_bucket(bucket_).http_response.message
      if response == 'No Content'
        puts "--- deleted bucket '" + bucket_ + "' ---"
        bucket_ = ""
      else 
        puts "--- could not deleted bucket '" + bucket_ + "' ---"
        puts "error: " + response
      end
      
    # exit
    when 'exit'
      puts "Goodbye..."
    
    # get
    when 'get'
      if tokens.size != 2
        puts "error: get <id>"
      else 
        if bucket_ == ''
          puts "error: bucket is not set"
        else 
          key = tokens[1]
          puts conn.get(bucket_, key).object.data
        end
      end            
    # getacl
    when 'getacl'
      if tokens.size != 3
        puts "error: getacl ['bucket'|'item'] <id>"
      else 
        object_type = tokens[1]
        case object_type
          when 'bucket'
            key = tokens[2]
            puts "--- ACL for bucket '" + key + "' ---"
            puts conn.get_bucket_acl(key).object.data
          when 'item'
            if bucket_ == ''
              puts "error: bucket is not set"
            else 
              key = tokens[2]
              puts "--- ACL for item '" + bucket_ + "/" + key + "' ---"
              puts conn.get_acl(bucket_, key).object.data
            end
          else 
              puts "syntax error: getacl ['bucket'|'item'] <id>"
        end            
      end      
    # getfile
    when 'getfile'
      if tokens.size != 3
        puts "error: getfile <id> <file>"
      else 
        if bucket_ == ''
          puts "error: bucket is not set"
        else 
          key = tokens[1]
          filename = tokens[2]
          data =  conn.get(bucket_, key).object.data
          File.open(filename, "wb") { |f| f.write(data) }  
          puts "got file '" + filename + "'"
        end
      end
    # gettorrent
    when 'gettorrent'
      if tokens.size != 2
        puts "error: gettorrent <id>"
      else 
        if bucket_ == ''
          puts "error: bucket is not set"
        else 
          key = tokens[1]
          data =  conn.get_torrent(bucket_, key).object.data
          torrent_file = key << '.torrent'
          File.open(torrent_file, "wb") { |f| f.write(data) }  
          puts "got file '" + torrent_file + "'"
        end    
      end
    
    # head
    when 'head'
      if tokens.size != 3
        puts "error: head ['bucket'|'id'] <id>"
      else 
        object_type = tokens[1]
        case object_type
          when 'bucket'
            bucket = tokens[2]
            puts conn.head(bucket).object.metadata
          when 'item'
            if bucket_ == ''
              puts "error: bucket is not set"
            else 
              id = tokens[2]
              puts conn.head(bucket_, id).object.metadata
            end
          else 
              puts "syntax error: head ['bucket'|'item'] <id>"
        end
      end     
    # help
    when 'help'
      print_help

    # host
    when 'host'
      if tokens.size != 2
        puts "error: host [hostname]"
      else 
        host_ = tokens[1]
        puts "--- host set to '" + host_ + "' ---"
      end

    # list
    when 'list'
      if bucket_ == ''
        puts "error: bucket is not set"
      else 
        puts "--- token list for bucket '" + bucket_ + "' ---"
        p conn.list_bucket(bucket_).entries.map { |entry| entry.key }
      end
      
    # listatom -- TODO: finish implementation
    when 'listatom'
      puts "--- command 'listatom' not currently implement ---"
    
    # listrss -- TODO: finish implementation
    when 'listrss'
      puts "--- command 'listrss' not currently implement ---"

    # listbuckets
    when 'listbuckets'
      puts "--- bucket list ---"
      p conn.list_all_my_buckets.entries.map { |bucket| bucket.name }

    # pass
    when 'pass'
      if tokens.size != 2
        puts "error: pass [password]"
      else 
        password_ = tokens[1]
        puts "--- password set to '" + password_ + "' ---"
      end

    # put
    when 'put'
      if tokens.size < 2
        puts "error: put <id> <data>"
      else 
        if bucket_ == ''
          puts "error: bucket is not set"
        else 
          key = tokens[1]
          contents = ''
          for i in 2..tokens.size
            if tokens[i] != nil
              if i == tokens.size
                contents += tokens[i]
              else 
                contents += tokens[i] + ' '
              end
            end
          end
          # put file with default 'private' ACL
          response =  conn.put(bucket_, key, contents,
                              {
                                "x-amz-acl" => "private",
                                "Content-Type" => "text/plain",
                                "Content-Length" =>  contents.size
                              }
                            ).http_response.message   
          if response == 'OK'
            puts "--- put item '" + bucket_ + "/" + key + "' ---"
          else 
            puts "--- could not put item '" + bucket_ + "/" + key + "' ---"
            puts "error: " + response
          end
        end
      end

    # putfile
    when 'putfile'
      if tokens.size != 3
        puts "error: putfile <id> <file>"
      else 
        if bucket_ == ''
          puts "error: bucket is not set"
        else 
          key = tokens[1]
          file = tokens[2]
          # put file with default 'private' ACL
          bytes = nil
          File.open(file, "rb") {|f| bytes = f.read }         
          headers =  { 
            'x-amz-acl' => 'private',
  #          'Content-Type' => 'application/octet-stream', 
  #          'Content-Disposition' => 'attachment; filename="' + file + '"', 
            'Content-Length' =>  FileTest.size(file).to_s
          }
          response =  conn.put(bucket_, key, bytes, headers).http_response.message   
          if response == 'OK'
            puts "--- put item '" + bucket_ + "/" + key + "' ---"
          else 
            puts "--- could not put item '" + bucket_ + "/" + key + "' ---"
            puts "error: " + response
          end
        end
      end

    # putfilewacl
    when 'putfilewacl'
      if tokens.size != 4
        puts "error: putfilewacl <id> <file> ['private'|'public-read'|'public-read-write'|'authenticated-read']"
      else 
        if bucket_ == ''
          puts "error: bucket is not set"
        else 
          key = tokens[1]
          file = tokens[2]
          acl = tokens[3]
          if CANNED_ACLS.include?(acl)
            # put file with specified ACL
            bytes = nil
            File.open(file, "rb") {|f| bytes = f.read }         
            headers =  { 
              'x-amz-acl' => acl,
#             'Content-Type' => 'application/octet-stream', 
#             'Content-Disposition' => 'attachment; filename="' + file + '"', 
              'Content-Length' =>  FileTest.size(file).to_s
            }
            response =  conn.put(bucket_, key, bytes, headers).http_response.message   
            if response == 'OK'
              puts "--- put item '" + bucket_ + "/" + key + "' with ACL '" + acl + "' ---"
            else 
              puts "--- could not put item '" + bucket_ + "/" + key + "' with ACL '" + acl + "' ---"
              puts "error: " + response
            end
          else 
              puts "error: invalid ACL '" + acl + "'"
          end
        end
      end

    # quit
    when 'quit'
      puts "Goodbye..."

    # setacl
    when 'setacl'
      if tokens.size != 4
        puts "error: setacl ['bucket'|'item'] \<id\> ['private'|'public-read'|'public-read-write'|'authenticated-read']"            
      else 
        object_type = tokens[1]
        case object_type
          when 'bucket'
            key = tokens[2]
            acl = tokens[3]
            if CANNED_ACLS.include?(acl)
              acl_xml = conn.get_bucket_acl(key).object.data
              case acl
                when 'public-read'
                  updated_acl = set_acl_public_read(acl_xml)
                  response = conn.put_bucket_acl(bucket_, updated_acl).http_response.message
                  puts "set ACL for bucket '" + bucket_ + "' to '" + acl + "'"
                when 'private'
                  updated_acl = set_acl_private(acl_xml)
                  response = conn.put_bucket_acl(bucket_, updated_acl).http_response.message
                  puts "set ACL for bucket '" + bucket_ + "' to '" + acl + "'"
                when 'public-read-write'
                  updated_acl = set_acl_public_read_write(acl_xml)
                  response = conn.put_bucket_acl(bucket_, updated_acl).http_response.message
                  puts "set ACL for bucket '" + bucket_ + "' to '" + acl + "'"
                when 'authenticated-read'
                  puts "ACL '" + acl + "' not supported at this time."             
              end
            else 
                puts "error: invalid ACL '" + acl + "'"
            end
          when 'item'
            if bucket_ == ''
              puts "error: bucket is not set"
            else 
              key = tokens[2]
              acl = tokens[3]
              if CANNED_ACLS.include?(acl)
                acl_xml = conn.get_acl(bucket_, key).object.data
                case acl
                  when 'public-read'
                    updated_acl = set_acl_public_read(acl_xml)
                    response = conn.put_acl(bucket_, key, updated_acl).http_response.message
                    puts "set ACL for item '" + bucket_ + "/" + key + "' to '" + acl + "'"
                  when 'private'
                    updated_acl = set_acl_private(acl_xml)
                    response = conn.put_acl(bucket_, key, updated_acl).http_response.message
                    puts "set ACL for item '" + bucket_ + "/" + key + "' to '" + acl + "'"
                  when 'public-read-write'
                    updated_acl = set_acl_public_read_write(acl_xml)
                    response = conn.put_acl(bucket_, key, updated_acl).http_response.message
                    puts "set ACL for item '" + bucket_ + "/" + key + "' to '" + acl + "'"
                  when 'authenticated-read'
                    puts "ACL '" + acl + "' not supported at this time."             
                end
              else 
                  puts "error: invalid ACL '" + acl + "'"
              end
            end
          else 
              puts "error: setacl ['bucket'|'item'] \<id\> ['private'|'public-read'|'public-read-write'|'authenticated-read']"            
        end
      end

    # user
    when 'user'
      if tokens.size != 2
        puts "error: user [username]"            
      else 
        user_ = tokens[1]
        puts "--- user set to '" + user_ + "' ---"
      end

    # no match
    else
      puts "no match" 
  end  
end until command == 'quit' or command == 'exit'

# end rSh3ll main
