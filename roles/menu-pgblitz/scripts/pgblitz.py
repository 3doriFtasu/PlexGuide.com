"""
A W.C.K.D. Automation Project

Made with love by NotTeresa
https://github.com/NotTeresa

"""

from __future__ import print_function
from google_auth_oauthlib.flow import Flow
from googleapiclient.discovery import build
from string import ascii_letters, digits
from secrets import choice
from base64 import b64decode
from time import sleep
import arrow
import argparse
import os

SCOPES = 'https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/cloud-platform'

#Adds a couple of options to the script
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbosity", action="count", default=0,
                    help="Show what's happening, \nuse -vv for super detailed logs")
parser.add_argument("-o", "--output", help="Output path of JSON files, defaults to: /opt/appdata/pgblitz/keys/automation")
parser.add_argument("-genSA","--generateServiceAccounts", help="Generates Service Accounts regardless of their presence", action="store_true")
args = parser.parse_args()
parser.parse_known_args()

#Checks if output path exists on the system
def output():
    if args.output:
        output = args.output.replace("'", "").replace('"', "")
        if os.path.isdir(output):
            return output
        else:
            print('\nOutput path does not exist')
            exit(1)
    else: return '/opt/appdata/pgblitz/keys/automation'

#Authorizes the application once
def auth():
    secrets = "credentials.json"
    flow = Flow.from_client_secrets_file(secrets, scopes=SCOPES, redirect_uri='urn:ietf:wg:oauth:2.0:oob')
    auth_url, _ = flow.authorization_url(prompt='consent')
    print('\nCopy & Paste and Visit the Following URL:\n {}'.format(auth_url))
    code = input('\nEnter the authorization code: ')
    token = flow.fetch_token(code=code)
    credentials = flow.credentials
    drive = build('drive', 'v3', credentials = credentials)
    iam = build('iam', 'v1', credentials = credentials)
    cloudresourcemanager = build('cloudresourcemanager', 'v1', credentials = credentials)
    servicemanagement = build('servicemanagement', 'v1', credentials = credentials)
    return {'drive': drive, 'iam': iam, 'cloudresourcemanager': cloudresourcemanager, 'servicemanagement': servicemanagement, 'token': token}

def auth2():
    secrets = "rclone.json"
    flow = Flow.from_client_secrets_file(secrets, scopes=SCOPES, redirect_uri='urn:ietf:wg:oauth:2.0:oob')
    auth_url, _ = flow.authorization_url(prompt='consent')
    print('\nWe need you to login again to configurate RCLONE. Use the same login credentials as you did just a few seconds ago!\n\nCopy & Paste and Visit the Following URL:\n {}'.format(auth_url))
    code = input('\nEnter the authorization code: ')
    token = flow.fetch_token(code=code)
    return {'token': token}

def gsuite(drive):
    check = drive.about().get(fields="canCreateTeamDrives").execute().get('canCreateTeamDrives')
    if args.verbosity >= 2: print('\nCan user create teamdrives: {}'.format(check))
    return check

def teamdriveExists(drive):
    valid = []
    for teamdrive in drive.teamdrives().list(fields="teamDrives(id, name)").execute().get('teamDrives'):
        canManageMembers = drive.teamdrives().get(fields='capabilities', teamDriveId=teamdrive['id']).execute().get('capabilities').get('canManageMembers')
        if args.verbosity >= 2: print('Can user add Service Accounts to: {} ({}): {}'.format(teamdrive['name'], teamdrive['id'], canManageMembers))
        if canManageMembers: valid.append({'id': teamdrive['id'], 'name': teamdrive['name']})
    if valid: return valid
    return False

#Looks for existing PG project, if none exist, it makes a new one
def listProject(cloudresourcemanager):
    projects = cloudresourcemanager.projects().list().execute().get('projects')
    if args.verbosity >= 2: print("Look for 'plexguide' within these projects:")
    project_id = None
    for project in projects:
        if args.verbosity >= 2 and 'active' in project['lifecycleState'].lower():
            print(project['projectId'])
        if 'active' in project['lifecycleState'].lower() and 'plexguide' in project['projectId']:
            project_id = project['projectId']
    if project_id:
        return project_id

def createProject(cloudresourcemanager):
    if args.verbosity >= 1: print("PlexGuide project does NOT exist, making new Google Cloud Project.")
    id_gen = ''.join(choice(digits) for i in range(8))
    project_body = {'projectId': 'plexguide-'+id_gen, 'name': 'PlexGuide'}
    cloudresourcemanager.projects().create(body=project_body).execute()
    if args.verbosity >= 1: print('\nNew Google Cloud Project created: '+ 'plexguide-'+id_gen)
    if args.verbosity >= 1: print('\nWaiting 5 seconds to make sure project is reachable.')
    sleep(5)
    return 'plexguide-'+id_gen

def enableAPI(servicemanagement, project):
    body = {'consumerId': 'project:'+project}
    servicemanagement.services().enable(serviceName="drive.googleapis.com", body=body).execute()

#Function for creating a nice menu
def selectOptions(datainput):
    while True:
        try: data = int(input("\nEnter option: "))
        except ValueError:
            print("Sorry, I didn't understand that. Please type the number.")
            continue
        if not 0 < int(data) <= len(datainput):
            print("Sorry, that is not an option.")
            continue
        else: break
    return data

#User can select how many TB he or she would like to upload
def accountsSelect():
    accounts = [4, 6, 10, 20, 40, 60]
    print('\nHow much data would you like to be able to upload on a daily basis?\nPlease enter the number in front of the amount of terabytes:')
    for option, account in enumerate(accounts, 1): print('{}. {} TB daily'.format(option,account * 0.75))
    userinput = selectOptions(datainput=accounts)
    return {'accounts': accounts[int(userinput)-1]}

def rcloneconfig(conffile, output):
    conffile = '\n'.join(conffile)
    with open(os.path.join(output,'rclone.conf'), 'w') as conf:
        conf.write(conffile)
    if args.verbosity >= 1: print('\nRclone configuration file written successfully')

#Creates Service Accounts
def serviceAccountsCreate(iam, project, output, template, conffile, teamdrive):
    if args.verbosity >= 1: print("No service accounts yet, prompting user to select number of accounts.")
    amount = accountsSelect()
    for number in range(1,amount['accounts'] + 1):
        account_body = {'accountId': 'pg-'+''.join(choice(digits) for i in range(8))}
        request = iam.projects().serviceAccounts().create(name='projects/' + project, body=account_body).execute()
        rename_body = {'displayName': 'PG'+format(number, '02d'), 'etag': request.get('etag')}
        rename = iam.projects().serviceAccounts().update(name=request.get('name'), body=rename_body).execute()
        if args.verbosity >= 2: print("Created "+rename.get('displayName')+" with identification: "+rename.get('name'))
        elif args.verbosity == 1: print(rename.get('displayName') + ' created')
        key_body = {'keyAlgorithm': 'KEY_ALG_RSA_2048', 'privateKeyType': 'TYPE_GOOGLE_CREDENTIALS_FILE'}
        keygen = iam.projects().serviceAccounts().keys().create(name=rename.get('name'), body=key_body).execute()
        with open(os.path.join(output,rename.get('displayName')), 'wb') as file:
            file.write(b64decode(keygen.get('privateKeyData')))
        rclone = template.format(rename.get('displayName'), os.path.join(output,rename.get('displayName')), teamdrive)
        conffile.append(rclone)
    sleep(5)
    return conffile

#Checks if Service Accounts already exist within the PG project
def serviceAccounts(iam, project, output, teamdrive, token):
    conffile = []
    template = "[{}]\ntype = drive\nclient_id =\nclient_secret =\nscope = drive\nroot_folder_id =\nservice_account_file = {}\nteam_drive = {}\n"
    tandgdrive = template+'token = {}\n'
    conffile.append(tandgdrive.format('gdrive', '', '', token))
    conffile.append(tandgdrive.format('tdrive', '', teamdrive, token))

    accounts = iam.projects().serviceAccounts().list(name='projects/' + project, pageSize='100').execute().get('accounts')
    if not accounts and not args.generateServiceAccounts:
        conffile = serviceAccountsCreate(iam=iam, project=project, output = output, template=template, conffile=conffile, teamdrive=teamdrive)
        rcloneconfig(conffile, output)
        return True
    elif not args.generateServiceAccounts:
        if args.verbosity >= 1: print("The following service accounts already exist:")
        for account in accounts:
            if args.verbosity >= 1: print(u'{0} ({1})'.format(account['displayName'], account['email']))
        answer = question("\nService Accounts already exist, should we invite those to your teamdrive and download the JSON files?")
        if answer == True:
            for account in accounts:
                key_body = {'keyAlgorithm': 'KEY_ALG_RSA_2048', 'privateKeyType': 'TYPE_GOOGLE_CREDENTIALS_FILE'}
                keygen = iam.projects().serviceAccounts().keys().create(name=account.get('name'), body=key_body).execute()
                with open(os.path.join(output,account.get('displayName')), 'wb') as file:
                    file.write(b64decode(keygen.get('privateKeyData')))
                rclone = template.format(account.get('displayName'), os.path.join(output,account.get('displayName')), teamdrive)
                conffile.append(rclone)
            rcloneconfig(conffile, output)
            return True
        else:
            return False
    elif args.generateServiceAccounts:
        conffile = serviceAccountsCreate(iam=iam, project=project, output = output, template=template, conffile=conffile, teamdrive=teamdrive)
        rcloneconfig(conffile, output)
        return True
    else:
        return False


#Easy function for asking yes / no questions
def question(question):
    valid = {"yes": True, "y": True, "yeah": True, "ye": True,
             "no": False, "n": False, "nope": False}
    while True:
        print(question + " [y/n]")
        choice = input().lower()
        if choice in valid: return valid[choice]
        else: print("Please respond with 'yes' or 'no' (or 'y' or 'n').")

def typeName():
    while True:
        try: data = input("\nWhat would you like to call your new teamdrive?\nType here: ")
        except ValueError:
            print("\nSorry, I didn't understand that. Please enter a name.")
            continue
        if not data:
            print("\nSorry, that is not an option. Please enter a name.")
            continue
        else: break
    return data

def teamdriveMenu():
    menu = ['Existing', 'New']
    print('\nWould you like to use an existing teamdrive or make a new one?')
    for option, teamdrive in enumerate(menu, 1): print('{}. {} teamdrive'.format(option,teamdrive))
    userinput = selectOptions(datainput=menu)
    return {'option': menu[int(userinput)-1]}

#Creates teamdrive
def teamdriveCreate(drive):
    teamdrive_name = typeName()
    teamdrive_body = {'name': teamdrive_name}
    teamdrive_create = drive.teamdrives().create(requestId=''.join(choice(ascii_letters + digits) for i in range(20)), body=teamdrive_body).execute()
    return {'id': teamdrive_create['id'], 'name': teamdrive_create['name']}

#Let the user select a teamdrive
def teamdriveSelect(valid):
    print('\nSelect teamdrive:')
    for option, item in enumerate(valid, 1): print('{}. {} ({})'.format(option,item['name'], item['id']))
    userinput = selectOptions(datainput=valid)
    return {'id': valid[int(userinput)-1]['id'], 'name': valid[int(userinput)-1]['name']}

def invite(iam, drive, project, id, name):
    emails = iam.projects().serviceAccounts().list(name='projects/' + project, pageSize='100').execute().get('accounts')
    for email in emails:
        invite_body = {'role': 'writer', 'type': 'user', 'emailAddress': email['email']}
        drive.permissions().create(fileId=id, supportsTeamDrives='true', body=invite_body).execute()
        if args.verbosity >= 1: print('Invited ' + email['displayName'] + ' to: ' + name)

def main(oauth, output):
    valid = teamdriveExists(drive=oauth['drive'])
    if not gsuite(drive=oauth['drive']) and not valid:
        print("Setup failed, user has no teamdrives and can't create teamdrives.")
        exit(1)
    else:
        getProject = listProject(cloudresourcemanager=oauth['cloudresourcemanager'])
        if not getProject:
            project = createProject(cloudresourcemanager=oauth['cloudresourcemanager'])
        else:
            if args.verbosity >= 1: print('\nPlexGuide project already exists! Using ' + getProject + ' as main PG project.')
            project = getProject
        enableAPI(servicemanagement=oauth['servicemanagement'], project=project)
        if valid:
            if args.verbosity >= 1: print('\nTeamdrive already exists, prompting user to choose between a new or existing teamdrive.')
            if gsuite(drive=oauth['drive']) and teamdriveMenu()['option'] == 'New':
                teamdrive = teamdriveCreate(drive=oauth['drive'])
            else:
                teamdrive = teamdriveSelect(valid=valid)
        else:
            if args.verbosity >= 1: print('\nTeamdrive does NOT exist, prompting user to create a teamdrive.')
            print("\nYou don't have a teamdrive yet!")
            teamdrive = teamdriveCreate(drive=oauth['drive'])
        if args.verbosity >= 1: print('Selected: {} ({})'.format(teamdrive['name'], teamdrive['id']))
        oauth2 = auth2()
        token = {"access_token":oauth2['token'].get('access_token'), "token_type":oauth2['token'].get('token_type'), "refresh_token":oauth2['token'].get('refresh_token'), "expiry":str(arrow.get(oauth2['token'].get('expires_at')))}
        token = str(token).replace("'", '"')
        SA = serviceAccounts(iam=oauth['iam'], project=project, output=output, teamdrive=teamdrive['id'], token=token)
        if SA:
            invite(iam=oauth['iam'], drive=oauth['drive'], project=project, id=teamdrive['id'], name=teamdrive['name'])
            print('\nGreat news! PGBlitz has succesfully been setup!')
        else:
            print('\nUser cancelled.')
            exit(1)

if __name__ == '__main__':
    output = output()
    oauth = auth()
    main(oauth, output)
