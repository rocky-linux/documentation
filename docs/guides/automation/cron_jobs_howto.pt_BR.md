---
title: Automações com cron
---

# Automação de processos com cron e crontab

## Pré-requisitos

* Um equipamento rodando Rocky Linux
* Sentir-se confortável em modificar arquivos de configuração usando a linha de comando com seu editor favorito (_vi_ será usado aqui)

## <a name="assumptions"></a> Suposições

* Conhecimento básico de bash, python ou quaisquer outras ferramentas de _scripting_/programação e o desejo de executar um _script_ automaticamente
* Que você está executando como usuário _root_ ou trocou para _root_ com o command `sudo -s`
**(Você pode executar _scripts_ em diretórios próprios com seu usuário. Nest caso não é necessário mudar para o usuário _root_.)**
* Assumimos que você é muito legal.

# Introdução

Linux provê o sistema _cron_, um agendador de tarefas baseado em tempo para automação de processos. É simples porem poderoso. Quer que um _script_ ou programa execute diariamente às 5 da tarde? Aqui é onde pode configurá-lo.

O _contrab_ é uma lista onde usuários adicionam suas tarefas e processos. Ele possui opções que podem simplificar as coisas. Este documento irá explorar uma quantidade destas opções. É bom para refrescar a memória daqueles que já possuem experiência e novos usuários podem adicionar o sistema _cron_ a seu repertório.

## <a name="starting-easy"></a>Começo simples - Os diretórios 'ponto' _cron_

Adicionado a todos os sistemas Linux, incluindo o Rocky Linux, os arquivos 'ponto' _cron_ ajudam a automatizar processos rapidamente. Estes aparecem como diretórios que o sistema cron chama baseado em sua convenção nominal. 

Em ordem para executar algo durante estes tempos auto definidos, tudo que você precisa fazer é copiar seu _script_ no diretório em questão e ter certeza que o mesmo é executável. Aqui está a lista de diretórios e horários que eles serāo executados:

* `/etc/cron.hourly/` - _Scripts_ colocados aqui irāo executar 1 minuto após cada hora, de todas horas diariamente.
* `/etc/cron.daily` - _Scripts_ colocados aqui irāo executar às 4:02 diariamente.
* `/etc/cron.weekly` - _Scripts_ colocados aqui irāo executar às 4:22 semanalmente todos os domingos.
* `/etc/cron.monthly` - _Scripts_ colocados aqui irāo executar às 4:42 mensalmente no primeiro dia do mês.

Desde que você esteja disposto a deixar o sistema executar seus _scripts_ em um dos horários prê-determinados, então facilita bastante colocá-los nesta pastas.

## Crise seu próprio _cron_

Of course, if the automated times don't work well for you for whatever reason, then you can create your own. In this example, we are assuming you are doing this as root. [see Assumptions](##-assumptions) To do this, type the following:

`crontab -e`

This will pull up root user's crontab as it exists at this moment in your chosen editor, and may look something like this. Go ahead and read through this commented version, as it contains descriptions of each field that we will be using next:

```
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

Notice that this particular crontab file has some of its own documentation built-in. That isn't always the case. When modifying a crontab on a container or minimalist operating system, the crontab will be an empty file, unless an entry has already been placed in it.

Let's assume that we have a backup script that we want to run at 10 PM at night. The crontab uses a 24 hour clock, so this would be 22:00. Let's assume that the backup script is called "backup" and that it is currently in the _/usr/local/sbin_ directory.

Note: Remember that this script needs to also be executable (`chmod +x`) in order for the cron to run it. To add the job, we would:

`crontab -e`

"crontab" stands for "cron table" and the format of the file is, in fact, a loose table layout. Now that we are in the crontab, go to the bottom of the file and add your new entry. If you are using vi as your default system editor, then this is done with the following keys:

`Shift : $`

Now that you are at the bottom of the file, insert a line and type a brief comment to describe what is going on with your entry. This is done by adding a "#" to the beginning of the line:

`# Backing up the system every night at 10PM`

Now hit enter. You should still be in the insert mode, so the next step is to add your entry. As shown in our empty commented crontab (above) this is **m** for minutes, **h** for hours, **dom** for day of month, **mon** for month, and **dow** for day of week.

To run our backup script every day at 10:00, the entry would look like this:

`00  22  *  *  *   /usr/local/sbin/backup`

This says run the script at 10 PM, every day of the month, every month, and every day of the week. Obviously, this is a pretty simple example and things can get quite complicated when you need specifics.

### The @options for crontab

As noted in the [Starting Easy](##-starting-easy) portion of this document above, scripts in the cron dot directories are run at very specific times. @options offer the ability to use more natural timing. The @options consist of:

* `@hourly` runs the script every hour of every day at 0 minutes past the hour.
* `@daily` runs the script every day at midnight.
* `@weekly` runs the script every week at midnight on Sunday.
* `@monthly` runs the script every month at midnight on the first day of the month.
* `@yearly` runs the script every year at midnight on the first day of January.
* `@reboot` runs the script on system startup only.

For our backup script example, if we used use the @daily option to run the backup script at midnight, the entry would look like this:

`@daily  /usr/local/sbin/backup`

### More Complex Options

So far, everything we have talked about has had pretty simple options, but what about the more complex task timings? Let's say that you want to run your backup script every 10 minutes during the day (probably not a very practical thing to do, but hey, this is an example!). To do this you would write:

`*/10  *   *   *   *   /usr/local/sbin/backup`

What if you wanted to run the backup every 10 minutes, but only on Monday, Wednesday and Friday?:

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

What about every 10 minutes every day except Saturday and Sunday?:

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

In the table, the commas let you specify individual entries within a field, while the dash lets you specify a range of values within a field. This can happen in any of the fields, and on multiple fields at the same time. As you can see, things can get pretty complicated.

When determining when to run a script, you need to take time and plan it out, particularly if the criteria are complex.

# Conclusions

The cron/crontab system is a very powerful tool for the Rocky Linux desktop user or systems administrator. It can allow you to automate tasks and scripts so that you don't have to remember to run them manually.

While the basics are pretty easy, you can get a lot more complex. For more information on crontab head up to the [crontab manual page](https://man7.org/linux/man-pages/man5/crontab.5.html). You can also simply do a web search for "crontab" which will give you a wealth of results to help you fine-tune your crontab skills.
