# Do nothing unless the target is RedHat or Debian based
{%- if grains['os_family'] == 'RedHat' or grains['os_family'] == 'Debian' %}
{%- from 'logstash_forwarder/map.jinja' import logstash_forwarder with context %}

include:
  - .repo

{%- if logstash_forwarder.cert_contents is defined %}
logstash-forwarder-cert:
  file.managed:
    - name: {{logstash_forwarder.cert_path}}
    - contents_pillar: logstash_forwarder:cert_contents
    - user: root
    - group: root
    - mode: 664
    - template: jinja
    - watch_in:
      - service: logstash-forwarder
{%- endif %}

logstash-forwarder-config:
  file.serialize:
    - name: /etc/logstash-forwarder
    - user: root
    - group: root
    - mode: 644
    - dataset_pillar: logstash_forwarder:config
    - formatter: json
    - watch_in:
      - service: logstash-forwarder

logstash-forwarder:
  pkg.latest:
    - name: {{logstash_forwarder.pkg}}
    - require:
      - pkgrepo: logstash-forwarder-repo
  file.managed:
    - name: /etc/init.d/{{logstash_forwarder.svc}}
    - user: root
    - group: root
    - mode: 755
    - source: {{ logstash_forwarder.init_file }}
    - template: jinja
    - watch_in:
      - service: logstash-forwarder
    - require:
      - pkg: logstash-forwarder
  service:
    - name: {{logstash_forwarder.svc}}
    - running
    - enable: true
    - require:
      - pkg: logstash-forwarder
      {%- if logstash_forwarder.cert_contents is defined %}
      - file: logstash-forwarder-cert
      {%- endif %}
{%- endif %}
