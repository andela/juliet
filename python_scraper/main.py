"""
Command-line application that does a search.
"""

__author__ = 'stanley.ndagi@andela.com'

import os
import sys
import json
import logging

from apiclient.discovery import build


logging.basicConfig(
    format='%(asctime)s %(message)s',
    datefmt='%m/%d/%Y %I:%M:%S %p',
    filename='retrieve.log',
    level=logging.INFO)


def write_to_file(results, file):
    # Handle edge-case if file is present and we don't want to run again
    with open(file, 'a+') as fh:
        fh.write(str(results)+'\n')


def write_to_file_json(results, file):
    # Handle edge-case if file is present and we don't want to run again
    with open(file, 'a+') as fh:
        fh.write(json.dumps(results)+'\n')


def gcse_retrieve(cx, scraper_name):
    # File manipulation
    json_file = scraper_name+'_output.json'
    txt_file = scraper_name+'_output.txt'
    open(json_file, 'w').close()
    open(txt_file, 'w').close()

    service = build(
        "customsearch",
        "v1",
        developerKey=os.getenv('dev_key'))

    """
    Only 10 pages request allowed :( bummer
    Valid info:
    https://productforums.google.com/forum/#!topic/customsearch/iafqT6dl2VM
    1, 11, 21, ..... to int(res['searchInformation']['totalResults'])
    """
    start_number = 1
    for i in range(10):
        res = service.cse().list(
            q='job',
            cx=cx,
            start=start_number
            ).execute()
        start_number += 10

        # Write the entire response object
        logging.info(
            'Started writing the response object of page {}'.format(i+1))
        write_to_file_json(res, json_file)
        logging.info('Finished')

        # Write the list of links from the results
        logging.info(
            'Started writing the links of page {}'.format(i+1))
        for i in res.get('items'):
            write_to_file(i.get('link'), txt_file)
        logging.info('Finished')


def boards_retrieve(jobs_board, url, page_sequence, pages):
    txt_file = '{}_urls.txt'.format(jobs_board)
    if not page_sequence:
        for i in range(pages):
            write_to_file(str(url)+str(i+1), txt_file)

if __name__ == '__main__':
    logging.basicConfig()
    # loop through the arguments from the command running this script
    for process in sys.argv[1:]:
        print('Running scraper for {}'.format(process))
        if process.lower() == 'icims':
            gcse_retrieve(os.getenv('icims_cx'), process)
        elif process.lower() == 'jobvite':
            gcse_retrieve(os.getenv('jv_cx'), process)
            print('{} scraper done!'.format(process))

        page_sequence = None
        pages = 20
        if process.lower() == 'zip':
            url = sys.argv[2]
            if len(sys.argv[2:]) > 1:
                page_sequence = sys.argv[3]
            elif len(sys.argv[2:]) > 2:
                page_sequence = sys.argv[3]
                pages = sys.argv[4]
            # python main.py zip URL
            # python main.py zip URL page
            boards_retrieve(process.lower(), url, page_sequence, pages)
            break
        if process.lower() == 'stack':
            url = sys.argv[2]
            if len(sys.argv[2:]) > 1:
                page_sequence = sys.argv[3]
            elif len(sys.argv[2:]) > 2:
                page_sequence = sys.argv[3]
                pages = sys.argv[4]
            # python main.py zip URL
            # python main.py zip URL page_sequence
            # python main.py zip URL page_sequence pages
            boards_retrieve(process.lower(), url, page_sequence, pages)
            break
        else:
            print(process+' is not supported yet.')
