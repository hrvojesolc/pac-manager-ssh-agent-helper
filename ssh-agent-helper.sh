#!/bin/bash

# Regular expression to test positive integer
re='^[0-9]+$';

#
# Test number of ssh-agent procs and do appropriate actions
#
procs=`ps -ef | grep -E " ssh-agent$" | awk '{print $2}' | wc -l`;
case $procs in
    0)
        echo "No ssh-agent processes found. Starting...";
        eval `ssh-agent` > /dev/null;
        if [ -e $1 ]; then
            ssh-add $1;
            echo "Exiting.";
        else
            echo "Script requires SSH key as first argument. Specified file does not exist. Exiting.";
            echo "Exiting.";
        fi;
        ;;
    1)
        agent_pid=`ps -ef | grep -E " ssh-agent$" | awk '{print $2}'`;
        agent_pid_in_dir=$((agent_pid - 1));
        if [ `find /tmp -type s 2>/dev/null | grep ssh | grep agent | grep $agent_pid_in_dir | wc -l` -ne 1 ]; then
            echo "One ssh-agent process and one ssh-agent folder, but invalid configuration. Remove and kill?"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes) rm -fr /tmp/ssh-*; kill -9 $agent_pid; break;;
                    No ) echo "Not configured. Exiting."; break;;
                esac
            done;
        else
            echo "Valid ssh-agent agent found. Configuring...";
            agent_file=`find /tmp -type s 2>/dev/null | grep ssh | grep agent | grep $agent_pid_in_dir`;
            export SSH_AGENT_PID=$agent_pid; export SSH_AUTH_SOCK=$agent_file;
            if [ -e ~/.ssh-agent-helper-env.sh ]; then rm ~/.ssh-agent-helper-env.sh; fi;
            echo "export SSH_AGENT_PID=$agent_pid;" >> ~/.ssh-agent-helper-env.sh;
            echo "export SSH_AUTH_SOCK=$agent_file;" >> ~/.ssh-agent-helper-env.sh;
            echo "Exported environment:";
            env | egrep '^SSH_AGENT_PID|^SSH_AUTH_SOCK';
            if [ "`ssh-add -L`" == "The agent has no identities." ]; then
                echo "ssh-agent has no identities. Trying to add...";
                if [ -e $1 ]; then
                    ssh-add $1;
                    echo "Exiting.";
                else
                    echo "Script requires SSH key as first argument. Specified file does not exist. Exiting.";
                    echo "Exiting.";
                fi;
            else
                echo "Listing keys (ssh-add -L):";
                ssh-add -L;
                echo "Exiting.";
            fi;
        fi;
        ;;
    *)
        cleaned=1;
        echo "You have more than one ssh-agent running, Checking and prompting...";
        for agent_dir in $(find /tmp -type d 2>/dev/null | grep ssh-); do
            agent_pid=`ls $agent_dir | grep agent | awk -F'.' '{print $2}'`;
            if ! [[ $agent_pid =~ $re ]] ; then
                echo "Would you like to remove invalid agent dir $agent_dir?";
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes) rm -fr $agent_dir; break;;
                        No ) cleaned=0; break;;
                    esac
                done;
            else
                agent_pid=$((agent_pid + 1));
                if [ `ps -ef | grep -E " ssh-agent$" | awk '{print $2}' | grep $agent_pid | wc -l` -eq 1 ]; then
                    echo "Valid agent found with PID ($agent_pid). Remove?";
                    select yn in "Yes" "No"; do
                        case $yn in
                            Yes) rm -fr $agent_dir; kill -9 $agent_pid; break;;
                            No ) cleaned=0; break;;
                        esac
                    done;
                else
                    echo "Would you like to remove invalid agent dir $agent_dir?";
                    select yn in "Yes" "No"; do
                        case $yn in
                            Yes) rm -fr $agent_dir; break;;
                            No ) cleaned=0; break;;
                        esac
                    done;
                fi;
            fi;
        done;
        for agent_pid in $(ps -ef | grep -E " ssh-agent$" | awk '{print $2}'); do
            echo "Would you like to kill ssh-agent process with PID ($agent_pid)?";
            select yn in "Yes" "No"; do
                case $yn in
                    Yes) kill -9 $agent_pid; break;;
                    No ) cleaned=0; break;;
                esac
            done;
        done;
        if [ $cleaned -eq 1 ]; then ~/.ssh-agent-helper.sh; fi;
        ;;
esac
