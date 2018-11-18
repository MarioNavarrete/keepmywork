from setuptools import setup

setup(
   name='keepmywork',
   version='1.13',
   description='few class to better life',
   author='Alexey Sudachen',
   author_email='alexey@sudachen.name',
   packages=['keepmywork'],
   install_requires=['pyotp', 'pexpect', 'sqlalchemy', 'pytest', 'pyyaml', 'pymysql'], 
   scripts=[],
   include_package_data=True, 
)

