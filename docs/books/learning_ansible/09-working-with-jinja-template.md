---
title: Working With Jinja Template in Ansible
author: Srinivas Nishant Viswanadha
contributors: Steven Spencer, Antoine Le Morvan, Ganna Zhyrnova
---

## Introduction

Ansible provides a powerful and straightforward way to manage configurations using Jinja templates through the built-in `template` module. This document explores two essential ways to utilize Jinja templates in Ansible:

- adding variables to a configuration file
- building complex files with loops and intricate data structures.

## Adding variables to a configuration file

### Step 1: Creating a Jinja template

Create a Jinja template file, e.g., `sshd_config.j2`, with placeholders for variables:

```jinja
# /path/to/sshd_config.j2

Port {{ ssh_port }}
PermitRootLogin {{ permit_root_login }}
# Add more variables as needed
```

### Step 2: Using the Ansible template module

In your Ansible playbook, use the `template` module to render the Jinja template with specific values:

```yaml
---
- name: Generate sshd_config
  hosts: your_target_hosts
  tasks:
    - name: Template sshd_config
      template:
        src: /path/to/sshd_config.j2
        dest: /etc/ssh/sshd_config
      vars:
        ssh_port: 22
        permit_root_login: no
      # Add more variables as needed
```

### Step 3: Applying configuration changes

Execute the Ansible playbook to apply the changes to the target hosts:

```bash
ansible-playbook your_playbook.yml
```

This step ensures that the configuration changes are applied consistently across your infrastructure.

## Building a complete file with loops and complex data structures

### Step 1: Enhancing the Jinja template

Extend your Jinja template to handle loops and complex data structures. Here's an example of configuring a hypothetical application with multiple components:

```jinja
# /path/to/app_config.j2

{% for component in components %}
[{{ component.name }}]
    Path = {{ component.path }}
    Port = {{ component.port }}
    # Add more configurations as needed
{% endfor %}
```

### Step 2: Integrating the Ansible template module

In your Ansible playbook, integrate the `template` module to generate a complete configuration file:

```yaml
---
- name: Generate Application Configuration
  hosts: your_target_hosts
  vars:
    components:
      - name: web_server
        path: /var/www/html
        port: 80
      - name: database
        path: /var/lib/db
        port: 3306
      # Add more components as needed
  tasks:
    - name: Template Application Configuration
      template:
        src: /path/to/app_config.j2
        dest: /etc/app/config.ini
```

Execute the Ansible playbook to apply the changes to the target hosts:

```bash
ansible-playbook your_playbook.yml
```

This step ensures that the configuration changes are applied consistently across your infrastructure.

The Ansible `template` module allows you to use Jinja templates to generate configuration files dynamically during playbook execution. This module lets you separate configuration logic and data, making your Ansible playbooks more flexible and maintainable.

### Key features

1. **Template Rendering:**
   - The module renders Jinja templates to create configuration files with dynamic content.
   - Variables defined in the playbook or inventory can be injected into templates, enabling dynamic configurations.

2. **Usage of Jinja2:**
   - The `template` module leverages the Jinja2 templating engine, providing powerful features like conditionals, loops, and filters for advanced template manipulation.

3. **Source and Destination Paths:**
   - Specifies the source Jinja template file and the destination path for the generated configuration file.

4. **Variable Passing:**
   - Variables can be passed directly in the playbook task or loaded from external files, allowing for flexible and dynamic configuration generation.

5. **Idempotent Execution:**
   - The template module supports idempotent execution, ensuring the template is only applied if changes are detected.

### Example playbook snippet

```yaml
---
- name: Generate Configuration File
  hosts: your_target_hosts
  tasks:
    - name: Template Configuration File
      template:
        src: /path/to/template.j2
        dest: /etc/config/config_file
      vars:
        variable1: value1
        variable2: value2
```

### Use cases

1. **Configuration Management:**
   - Ideal for managing system configurations by dynamically generating files based on specific parameters.

2. **Application Setup:**
   - Useful for creating application-specific configuration files with varying settings.

3. **Infrastructure as Code:**
   - Facilitates Infrastructure as Code practices by allowing dynamic adjustments to configurations based on variables.

### Best practices

1. **Separation of Concerns:**
   - Keep the actual configuration logic in Jinja templates, separating it from the playbook's main structure.

2. **Version Control:**
   - Store Jinja templates in version-controlled repositories for better tracking and collaboration.

3. **Testability:**
   - Test templates independently to ensure they produce the expected configuration output.

By leveraging the `template` module, Ansible users can enhance the manageability and flexibility of configuration tasks, promoting a more streamlined and efficient approach to system and application setup.

### References

[Ansible Template Module Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html).
