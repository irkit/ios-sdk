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

  def sync_with_csv( csv_string )
    csv_keys = []
    worksheet = @spreadsheet.worksheets.first
    spreadsheet_rows = worksheet.list.to_hash_array

    csv = CSV.new( csv_string, {
        headers:        :first_row,
        return_headers: true,
      })
    csv.each do |csv_row|
      if csv_row.header_row?
        # nil terminated
        csv_keys = csv_row.fields
        csv_keys.select! {|key| key && ! key.empty? }

        # update keys if new ones appear
        newlistkeys         = worksheet.list.keys | csv_keys
        if worksheet.list.keys.length != newlistkeys.length
          worksheet.list.keys = newlistkeys
          puts "udpated header row"
        end

        next
      end

      found = spreadsheet_rows.index { |r| r["Part"] == csv_row.field("Part") }

      if found != nil
        # update
        csv_row.each do |key,value|
          if key && ! key.empty? && ( worksheet.list[ found ][ key ] != value )
            puts "updating row[ #{found} ][ #{key} ] = #{value}"
            worksheet.list[ found ][ key ] = value
          end
        end
      else
        # create
        new_row = {}
        csv_row.each do |key,value|
          new_row[ key ] = value if (key && ! key.empty?)
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
