# juliet2

### Setup

Create a file `keys.sh` to enter your secret keys in the format:

```sh
#!/bin/zsh
echo "Updating keys ..."

icims_cx="__ x __"
dev_key="__ x __"
sheet_id="__ x __"
export cx
echo $cx
export dev_key
echo $dev_key
export sheet_id
echo $sheet_id

echo "Done
```

Create a virtual environment and run:

```sh
pip install -r requirements.txt
```

### Run ATS Script

Run:
```
$ source keys.sh
$ python main.py icims
$ scrapy crawl icims
```

#### Result

This will produce 3 files:
- `output.txt` (containing 100 links)
- `output.json` (containing the response object of the 10 pages) and
- `retrieve.log` (containing the logs)
- `job_opening_icims.csv` (containing the data in csv)

### Run Jobs Board Script

Run:
```
$ python main.py zip https://www.ziprecruiter.com/jobs/technology/
$ scrapy crawl zipone
$ scrapy crawl ziptwo
```
#### Result

This will produce 3 files:
- `_urls.txt` (containing Board's links)
- `zipone_output.txt` (containing the links of the job openings) and
- `ziptwo_output.csv` (containing the data in csv)

### Docker

If you're running this in a VPS simply:
1. Install **Docker**
2. Git clone the project. Since this is a private repo do it this way:

   Get a token from [here](https://github.com/settings/tokens) for access to private repositories and run

   `git clone https://TOKEN@github.com/NdagiStanley/juliet2 juliet`
3. Run `cd juliet`
4. Run `docker build -t juliet .`
5. Run
    ```
    docker run -e "icims_cx=____" -e "jv_cx=____" -e "dev_key=____" -v `pwd`:/usr/src/app juliet
    ```