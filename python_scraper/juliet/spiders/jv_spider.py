# -*- coding: utf-8 -*-
import scrapy


class IcimsSpider(scrapy.Spider):
    name = "jobvite"
    input_file = '{}_output.txt'.format(name)
    csv_file = 'job_opening_{}.csv'.format(name)

    def list_of_urls(self, file):
        try:
            with open(file) as fp:
                # remove trailing whitespace element in the list
                return fp.read().split('\n')[:-1]
        except FileNotFoundError as e:
            if e.errno == 2:
                print('Confirm that you\'ve run - python main.py before this!')
                print('Press Enter and run python main.py ....')
                input()

    def parse(self, response):
        listing = []
        with open(self.csv_file, 'a+') as f:
            # Title of job opening
            title = response.css('title::text').extract_first()
            schema = [title]
            # listing = ['job title', 'job desc' ...]
            listing.extend(schema)
            f.write((', ').join(listing) + '\r\n')

    def start_requests(self):
        urls = self.list_of_urls(self.input_file)
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)
        self.log('Writing to csv file - {}'.format(self.csv_file))
