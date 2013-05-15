#!/usr/bin/env python

import os, os.path

# Generates resource file from each po file.
# And also other configuration stuff too.

desc_h = """<?xml version='1.0' encoding='UTF-8'?>
<description xmlns="http://openoffice.org/extensions/description/2006"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:d="http://openoffice.org/extensions/description/2006">
<identifier value="mytools.sheet.QuadraticEquationAddIn" />
<version value="{VERSION}" />
<dependencies>
{DEPS}
</dependencies>
<!--
<registration>
<simple-license accept-by="admin" default-license-id="this" suppress-on-update="true" suppress-if-required="true">
<license-text xlink:href="LICENSE" lang="en" license-id="this" />
</simple-license>
</registration>
-->
<display-name>
{NAMES}
</display-name>
<extension-description>
{DESCRIPTIONS}
</extension-description>
<!--
<update-information>
<src xlink:href="https://raw.github.com/hanya/QuadraticEq/master/files/qd.update.xml"/>
</update-information>
-->
</description>"""

min_deps = """<OpenOffice.org-minimal-version value="{MINIMAL_VERSION}" d:name="OpenOffice.org {MINIMAL_VERSION}" />"""
max_deps = """<d:OpenOffice.org-maximal-version value="{MAXIMAL_VERSION}" d:name="OpenOffice.org {MAXIMAL_VERSION}" />"""

update_feed = """<?xml version="1.0" encoding="UTF-8"?>
<description xmlns="http://openoffice.org/extensions/update/2006" 
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:d="http://openoffice.org/extensions/description/2006">
<identifier value="mytools.sheet.QuadraticEquationAddIn" />
<version value="{VERSION}" />
<dependencies>
{DEPS}
</dependencies>
<update-download>
<src xlink:href="https://raw.github.com/hanya/QuadraticEq/master/files/qd-{VERSION}.oxt"/>
</update-download>
</description>
"""

addininfo_xcu = """<?xml version='1.0' encoding='UTF-8'?>
<oor:component-data 
xmlns:oor="http://openoffice.org/2001/registry" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
oor:package="org.openoffice.Office"
oor:name="CalcAddIns">
  <node oor:name="AddInInfo">
    <node oor:name="mytools.sheet.QuadraticEquationAddIn" oor:op="replace">
      <node oor:name="AddInFunctions">
        <node oor:name="quadratic" oor:op="replace">
          <prop oor:name="DisplayName">
            <value>QUADRATIC</value>
          </prop>
          <prop oor:name="Description">
            {id_quadratic_description}
          </prop>
          <prop oor:name="Category">
            <value>Mathematical</value>
          </prop>
          <node oor:name="Parameters">
            <node oor:name="a" oor:op="replace">
              <prop oor:name="DisplayName">
                {id_quadratic_a_name}
              </prop>
              <prop oor:name="Description">
                {id_quadratic_a_description}
              </prop>
            </node>
            <node oor:name="b" oor:op="replace">
              <prop oor:name="DisplayName">
                {id_quadratic_b_name}
              </prop>
              <prop oor:name="Description">
                {id_quadratic_b_description}
              </prop>
            </node>
            <node oor:name="c" oor:op="replace">
              <prop oor:name="DisplayName">
                {id_quadratic_c_name}
              </prop>
              <prop oor:name="Description">
                {id_quadratic_c_description}
              </prop>
            </node>
            <node oor:name="nType" oor:op="replace">
              <prop oor:name="DisplayName">
                {id_quadratic_type_name}
              </prop>
              <prop oor:name="Description">
                {id_quadratic_type_description}
              </prop>
            </node>
          </node>
        </node>
      </node>
    </node>
  </node>
</oor:component-data>
"""

def write_update_feed(name, minimal_version="4.0", maximal_version=None):
    version = read_version()
    args = {"VERSION": version}
    deps = []
    if minimal_version:
        deps.append(min_deps.format(MINIMAL_VERSION=minimal_version))
    if maximal_version:
        deps.append(max_deps.format(MAXIMAL_VERSION=maximal_version))
    if deps:
        args["DEPS"] = "\n".join(deps)
    else:
        args["DEPS"] = ""
    
    s = update_feed.format(**args)
    with open(os.path.join(".", "files", name), "w") as f:
        f.write(s.encode("utf-8"))


def genereate_description(d, out_dir, label_id, desc_id, minimal_version="4.0", maximal_version=None):
    version = read_version()
    
    names = []
    for lang, v in d.iteritems():
        name = v[label_id]
        names.append("<name lang=\"{LANG}\">{NAME}</name>".format(LANG=lang, NAME=name.encode("utf-8")))
    
    descs = []
    for lang, v in d.iteritems():
        desc = v[desc_id]
        with open(os.path.join(out_dir, "descriptions/desc_{LANG}.txt").format(LANG=lang), "w") as f:
            f.write(desc.encode("utf-8"))
        descs.append("<src lang=\"{LANG}\" xlink:href=\"descriptions/desc_{LANG}.txt\"/>".format(LANG=lang))
    
    args = {"VERSION": version, "NAMES": "\n".join(names), "DESCRIPTIONS": "\n".join(descs)}
    deps = []
    if minimal_version:
        deps.append(min_deps.format(MINIMAL_VERSION=minimal_version))
    if maximal_version:
        deps.append(max_deps.format(MAXIMAL_VERSION=maximal_version))
    if deps:
        args["DEPS"] = "\n".join(deps)
    else:
        args["DEPS"] = ""
    return desc_h.format(**args)


def read_version():
    with open("VERSION") as f:
        return f.read().strip()

class XCUDataTemplated(object):
    
    TEMPLATE = ""
    
    def __init__(self):
        self.template = None
        self._replacements = {}
    
    def add_value_for_locales(self, replaced_key, k, d):
        a = []
        locales = list(d.iterkeys())
        locales.sort()
        for lang in locales:
            _d = d[lang]
            a.append("<value xml:lang=\"{LANG}\">{VALUE}</value>".format(VALUE=_d[k].encode("utf-8"), LANG=lang))
        self._add_replacement(replaced_key, "\n".join(a))
    
    def _add_replacement(self, key, value):
        self._replacements[key] = value
    
    def _format(self):
        return self.template.format(**self._replacements)
    
    def generate(self, d):
        self.template = self.__class__.TEMPLATE
        self._generate(d)
        return self._format()


class AddInInfoXCU(XCUDataTemplated):
    
    TEMPLATE = addininfo_xcu
    
    def _generate(self, d):
        for k, v in d["en-US"].iteritems():
            self.add_value_for_locales(k, k, d)


def extract_from_po(d, locale, lines):
    msgid = msgstr = id = ""
    for l in lines:
        #if l[0] == "#":
        #    pass
        if l[0:2] == "#,":
            pass
        elif l[0:2] == "#:":
            id = l[2:].strip()
        if l[0] == "#":
            continue
        elif l.startswith("msgid"):
            msgid = l[5:]
        elif l.startswith("msgstr"):
            msgstr = l[6:].strip()
            #print(id, msgid, msgstr)
            if msgstr and id:
                d[id] = msgstr[1:-1].decode("utf-8").replace('\\"', '"')
        _l = l.strip()
        if not _l:
            continue


def read_po_files():
    locales = {}
    po_dir = os.path.join(".", "po")
    
    for po in os.listdir(po_dir):
        if po.endswith(".po"):
            locale = po[:-3]
            try:
                lines = open(os.path.join(po_dir, po)).readlines()
            except:
                print("%s can not be opened")
            d = {}
            extract_from_po(d, locale, lines)
            locales[locale] = d
    
    return locales


import argparse

def main():
    default_minimal_version = "3.4"
    parser = argparse.ArgumentParser(description="Generates resources for the package")
    parser.add_argument("-min", dest="min", default=default_minimal_version, 
                        help="Minimal-version dependencies in description.xml")
    parser.add_argument("-max", dest="max", default=None, 
                        help="Maximal-version dependencies in description.xml")
    args = parser.parse_args()
    min_version = args.min
    max_version = args.max
    
    out_dir = "gen"
    locales = read_po_files()
    
    def store_xcu_data(klass, out):
        with open(os.path.join(out_dir, out), "w") as f:
            f.write(klass().generate(locales))
    
    store_xcu_data(AddInInfoXCU, "AddInInfo.xcu")
    
    with open(os.path.join(out_dir, "description.xml"), "w") as f:
        f.write(genereate_description(locales, out_dir, 
            "id_name", "id_description", min_version, max_version))
    
    write_update_feed("qd.update.xml", min_version, max_version)


if __name__ == "__main__":
    main()
