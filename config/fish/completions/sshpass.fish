# Description: Completions for sshpass

# Define the options for sshpass
complete -c sshpass -s p -l password -d 'Provide the password'
complete -c sshpass -s f -l password-file -d 'File containing the password'
complete -c sshpass -s d -l display -d 'Display password prompt'
complete -c sshpass -s v -l verbose -d 'Verbose mode'
complete -c sshpass -s e -l echo -d 'Disable echo of password'
complete -c sshpass -s P -l prompt -d 'Specify custom password prompt'

# Suggest common commands to use with sshpass
complete -c sshpass -f -a 'ssh scp rsync sftp' -d 'Command to execute'
