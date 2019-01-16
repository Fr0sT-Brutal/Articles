Tips for building reliable network server
=========================================

Control server's resourses
--------------------------

  - Number of connections. Limit the number of per-address connections
  - Number of active clients. Limit the number, disconnect inactive clients
  
Protect from DOS
----------------

  - Limit allowed interval between connections if connection was closed
  - Limit allowed interval between requests
  - Throttle input/output streams
  - Filter addresses allowed to connect
  - Limit time a client is allowed to write request and read response (slow HTTP headers attack). Close connection if client reads too slowly
  - Limit request size

Protect from auth hacking
-------------------------

  - Wait for some time before responsing (bruteforce attacks)
  - Wait for random time after auth check and/or use safe comparisons (timing attacks)
  - Add timeout after failed attempts
  - Protect from MITM, cookies interception