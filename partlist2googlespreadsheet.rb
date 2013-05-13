#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "google_drive"
require "pit"
require "csv"

class PartSheet

  attr_reader :spreadsheet

  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
  end

  def url
    @spreadsheet.human_url
  end

  def self.open(username, password, title)
    session     = GoogleDrive.login(username, password)
    spreadsheet = session.spreadsheet_by_title(title)
    new(spreadsheet)
  end

  def sync_with_csv( csv )
    csv_keys = []
    firstline = true
    worksheet = @spreadsheet.worksheets.first
    spreadsheet_rows = worksheet.list.to_hash_array

    CSV.parse( csv ) do |csv_row|
      csv_row.compact!

      if firstline
        firstline = false

        # nil terminated
        csv_keys = csv_row.compact! || csv_row

        # update keys if new ones appear
        newlistkeys = worksheet.list.keys | csv_keys
        worksheet.list.keys = newlistkeys if worksheet.list.keys.length != newlistkeys.length
        next
      end

      found = spreadsheet_rows.index {|r| r["Part"] == csv_row[ 0 ]}

      if found != nil
        # update
        csv_row.each_index do |index|
          if worksheet.list[ found ][ csv_keys[ index ] ] != csv_row[ index ]
            puts "updating row[ #{index} ] = #{csv_row[index]}"
            worksheet.list[ found ][ csv_keys[ index ] ] = csv_row[ index ]
          end
        end
      else
        # create
        new_row = {}
        csv_keys.each_index do |index|
          new_row[ csv_keys[ index ] ] = csv_row[ index ]
        end
        worksheet.list.push( new_row )
        puts "created new row: #{new_row}"
      end

    end

    if worksheet.dirty?
      worksheet.save
    else
      puts "no changes"
    end
  end

end

def main
  if ARGV.size < 2 then
    abort "usage: ruby #{$0} spreadsheet-title semi-collon-separated-csvfile"
  end
  title               = ARGV[ 0 ]
  semicollon_csv_file = ARGV[ 1 ]

  config = Pit.get( "partlist2googlespreadsheet - #{title}",
    :require => {
      "username" => "your email in google spreadsheet for #{title}",
      "password" => "your password in google spreadsheet for #{title}",
    }
  )
  sheet = PartSheet.open( config["username"], config["password"], title )

  puts "writing spreadsheet at URL: #{sheet.url}"

  csv = IO.read( semicollon_csv_file ).gsub( /\";/, "\"," )

  sheet.sync_with_csv( csv )
end

main
