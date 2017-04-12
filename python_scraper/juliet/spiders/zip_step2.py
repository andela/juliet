# -*- coding: utf-8 -*-
import arrow
import re
import scrapy

from cleanco import cleanco


class IcimsSpider(scrapy.Spider):
    date = arrow.now('US/Pacific').format('YYYY-MM-DD')
    name = "ziptwo"
    source = "ziprecruiter.com"
    input_file = 'zipone_output.txt'
    output_file = '{}_output.csv'.format(name)

    def list_of_urls(self, file):
        try:
            with open(file) as fp:
                # remove trailing whitespace element in the list
                return fp.read().split('\n')[:-1]
        except FileNotFoundError as e:
            if e.errno == 2:
                print('Confirm that you\'ve run - \
                       python main.py and scrapy crawl zipone before this!')
                print('Press Enter and run \
                       python main.py and/ or scrapy crawl zipone ....')
                input()

    def handle_characters(self, schema_item):
        for character in ['\n', '\r', '   ']:
            if character in schema_item:
                schema_item = schema_item.replace(character, "")
        schema_item = schema_item.replace(',', '|')
        return schema_item

    def parse(self, response):
        with open(self.output_file, 'a+') as f:
            entries = []
            # Title
            title = response.css("h1.job_title::text").extract_first()
            # Company name
            co = cleanco(response.css(
                "span.t_company_name a::text")[1].extract())
            co_name = co.clean_name()
            # Location
            location = ''
            for i in response.css("h3 a::attr(href)").extract():
                if 'maps.google' in i:
                    result = re.match('.*%20(.*)&z=9', i)
                    location = result.group(1)
            # Company url
            co_url = ''
            # Scraping url
            url = response.url
            # Job description
            description = ' '.join(response.css(
                "div.jobDescriptionSection p::text").extract())
            # Job requirements
            requirements = ''
            # Job responsibilities
            responsibilities = ''
            # Date scraped - self.date
            # Source - self.source
            schema = [title, co_name, location, co_url, url, description,
                      requirements, responsibilities, self.date, self.source]
            new_schema = []
            for schema_item in schema:
                schema_item = self.handle_characters(schema_item)
                new_schema.append(schema_item)
            entries.extend(new_schema)
            f.write(', '.join(entries) + '\r\n')

    def start_requests(self):
        urls = self.list_of_urls(self.input_file)
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)
        self.log('Writing to step 2 file - {}'.format(self.output_file))
