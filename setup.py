from setuptools import setup
from pathlib import Path
with Path("README.md").open() as readme:
    readme = readme.read()

version = 0.1
setup(
    # distclass=BinaryDistribution,
    name="smlfs",
    version=version if isinstance(version, str) else str(version),
    keywords="Standard MLFS compiler",  # keywords of your project that separated by comma ","
    description="",  # a concise introduction of your project
    long_description=readme,
    long_description_content_type="text/markdown",
    license="mit",
    python_requires=">=3.7",
    url="https://github.com/thautwarm/MLFS.jl",
    author="thautwarm",
    author_email="twshere@outlook.com",
    py_modules=["mlfs_lex", "mlfs_parser", "mlfsc", "mlfsf"],
    entry_points = {
         "console_scripts": [
             "mlfsc=mlfsc:entry"
         ]
    },
    # above option specifies what commands to install,
    # e.g: entry_points={"console_scripts": ["yapypy=yapypy.cmd:compiler"]}
    install_requires=["wisepy2>=1.1.1"],  # dependencies
    platforms="any",
    classifiers=[
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: Implementation :: CPython",
    ],
    zip_safe=False,
)