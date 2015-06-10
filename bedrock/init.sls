{% from "bedrock/map.jinja" import bedrock with context %}


include:
  - git.package
  - users

{{ salt['pillar.get']('repository:lookup:server', 'none') }}:
  ssh_known_hosts:
    - present
    - user: {{ salt['pillar.get']('repository:lookup:user', 'none') }}
    - fingerprint: {{ salt['pillar.get']('repository:lookup:fingerprint', 'none') }}
    - port: {{ salt['pillar.get']('repository:lookup:ssh_port', '22') }}

{{ salt['pillar.get']('repository:lookup:namespace', 'none') }}-{{ salt['pillar.get']('repository:lookup:project', 'none') }}:
  git.latest:
    - name: ssh://git@{{ salt['pillar.get']('repository:lookup:server', 'none') }}:{{ salt['pillar.get']('repository:lookup:ssh_port', 'none') }}/{{ salt['pillar.get']('repository:lookup:namespace', 'none') }}/{{ salt['pillar.get']('repository:lookup:project', 'none') }}.git
    - rev: {{ salt['pillar.get']('repository:lookup:branch', 'master') }}
    - target: {{ salt['pillar.get']('repository:lookup:doc_root', '/var/www') }}/{{ salt['pillar.get']('repository:lookup:project', 'none') }}
    - identity: {{ salt['pillar.get']('repository:lookup:identity', 'none') }}
    - user: {{ salt['pillar.get']('repository:lookup:user', 'www-data') }}
    - require:
      - pkg: git
      - user: {{ salt['pillar.get']('repository:lookup:user', 'none') }}
      - ssh_known_hosts: {{ salt['pillar.get']('repository:lookup:server', 'none') }}


.env:
  file.managed:
    - name: {{ bedrock.base }}/.env
    - source: salt://bedrock/files/.env.tmpl
    - template: jinja
    - user: {{ bedrock.user }}
    - group: {{ bedrock.user }}
    - context:
        bedrock: {{ bedrock }}
    - require:
      - git: {{ salt['pillar.get']('repository:lookup:namespace', 'none') }}-{{ salt['pillar.get']('repository:lookup:project', 'none') }}

composer-install:
  cmd.run:
    - name: composer install
    - cwd: {{ salt['pillar.get']('repository:lookup:doc_root', '/var/www') }}/{{ salt['pillar.get']('repository:lookup:project', 'none') }}
    - require:
      - file: .env
    - user: {{ bedrock.user }}

