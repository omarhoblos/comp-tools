print("Started Adding the Users.");

rs.initiate();
rs.status();

print("Waiting!");

while (! db.isMaster().ismaster ) { sleep(1000) }

print("Creating!");

cdr = db.getSiblingDB('cdr');
cdr.createUser({ user: 'mongo', pwd: '$PASSWORD', roles: [ { role: 'readWrite', db: 'cdr' } ]});

print("End Adding the User Roles.");