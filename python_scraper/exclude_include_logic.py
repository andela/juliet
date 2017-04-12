
from scrapy.utils.log import configure_logging


configure_logging(install_root_handler=False)
logging.basicConfig(
    filename='ziptwo.log',
    format='%(levelname)s: %(message)s',
    level=logging.WARNING
)
logger = logging.getLogger(__name__)

import logging
    def log_warning(self):
        return logger.warning("Did not meet conditions for exclusions and inclusions")


list_for_fed = ['senior', 'Lead', 'Director', 'Manager', 'specialist', 'experienced', 'part-time', 'experienced', 'Instructor', 'Co-Founder', 'CTO', 'intern', 'internship', 'test', 'solution', 'scrum-master', 'ux', 'designer']
list_for_mld = ['Director', 'Manager', 'specialist', 'part-time', 'Instructor', 'Co-Founder', 'CTO', 'intern', 'internship', 'test', 'solution', 'scrum-master', 'ux', 'designer']
list_for_sld = ['specialist', 'part-time', 'Instructor', 'Co-Founder', 'CTO', 'intern', 'internship', 'test', 'solution', 'scrum-master', 'ux', 'designer']
list_for_the_rest = ['part-time', 'Instructor', 'Co-Founder', 'CTO', 'intern', 'internship', 'test', 'solution', 'scrum-master', 'ux']

list_for_fed_desc = ['5+', 'Sr. ', 'Sr ', '.Sr ', 'Ph.D ', 'PhD', 'mid', 'seasoned']
list_for_mld_desc = ['5+', 'Sr. ', 'Sr ', '.Sr ', 'Ph.D ', 'PhD']
list_for_sld_desc = ['Ph.D ', 'PhD']

if "Front-end Developer" or "Back-end Developer" or "Mobile Developer" and (word for word in list_for_fed in title):
    # if (word for word in list_for_fed_desc) in job_desc:
    self.log_warning()
    return
elif "Mid-Level Developer" and (word for word in list_for_mld in title):
    self.log_warning()
    return
elif "Senior Developer" and (word for word in list_for_sld in title):
    self.log_warning()
    return
elif "Technical Product Manager" or "DevOps Engineer" or "QA/Test Engineer" or "Engineering Manager" or "VP Engineering" and (word for word in list_for_the_rest in title):
    return
else: