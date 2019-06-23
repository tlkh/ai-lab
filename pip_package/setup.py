import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="ai_lab_gui",
    version="0.0.4",
    author="Timothy Liu",
    author_email="timothyl@nvidia.com",
    description="Beginner's GUI for the AI Lab container",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/NVAITC/ai-lab",
    packages=setuptools.find_packages(),
    include_package_data=True,
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Operating System :: POSIX :: Linux ",
        "Topic :: Scientific/Engineering :: Artificial Intelligence"
    ],
    entry_points = {
        'console_scripts': ['ai_lab=ai_lab_gui.app:main'],
    },
    install_requires=[
        'docker',
        'flask'
    ]
)

