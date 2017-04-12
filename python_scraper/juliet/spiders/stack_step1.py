# -*- coding: utf-8 -*-
import scrapy


class IcimsSpider(scrapy.Spider):
    name = "stackone"
    input_file = 'stack_urls.txt'
    output_file = '{}_output.txt'.format(name)

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
        with open(self.output_file, 'a+') as f:
            # Links of job openings
            entries = response.css(
                "div.-title a.job-link::attr(href)").extract()
            for entry in entries:
                f.write(entry + '\n')

    def start_requests(self):
        urls = self.list_of_urls(self.input_file)
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)
        self.log('Writing to step 2 file - {}'.format(self.output_file))
