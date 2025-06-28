from setuptools import setup, find_packages

# Read requirements
with open('requirements.txt') as f:
    requirements = [line.strip() for line in f.readlines() if line.strip() and not line.startswith('#')]

setup(
    name="bitcoin-dca",
    version="1.0.0",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            'btc-dca=bitcoin_dca.main:main',
        ],
    },
    author="Bitcoin DCA Analyzer",
    description="Bitcoin DCA Analysis Terminal Application",
    long_description=open('README.md').read(),
    long_description_content_type="text/markdown",
    python_requires=">=3.8",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Financial and Insurance Industry", 
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
)