
-- Logged user
SELECT id
FROM users u
WHERE u.database_user_name = "current_user"()
;


-- Table privilege
SELECT
   table_catalog, table_schema, table_name, privilege_type, grantor, grantee
FROM
   information_schema.table_privileges
WHERE 1=1
    AND grantee = 'administrator'
--    AND grantee = 'user_one'
--    AND grantee <> 'postgres'
    AND table_schema <> 'pg_catalog'
--    AND table_schema <> 'information_schema'
--    AND table_schema <> 'public'
;

--
-- "use strict";
--
-- let UserSession = require('./UserSession');
-- let TripDAO = require('./TripDAO');
--
-- class TripService {
--     getTripsByUser(user) {
--         let tripList = [];
--         let loggedUser = UserSession.getLoggedUser();
--         let isFriend = false;
--         if (loggedUser != null) {
--             let friends = user.getFriends();
--             for (let i=0; i < friends.length; i++) {
--                 let friend = friends[i];
--                 if (friend == loggedUser) {
--                     isFriend = true;
--                     break;
--                 }
--             };
--             if (isFriend) {
--                 tripList = TripDAO.findTripsByUser(user);
--             }
--             return tripList;
--         } else {
--             throw new Error('User not logged in.');
--         }
--     }
-- }
--
-- module.exports =

SELECT
    u.name,
    u_f.name
FROM users u
    INNER JOIN friendships f ON f.user_id = u.id
        INNER JOIN users u_f ON u_f.id = f.friend_user_id
AND u.name = 'Helen'
;

SELECT
    u.name,
    t.place
FROM users u
    INNER JOIN trips t ON t.user_id = u.id
AND u.name = 'Jim'
;



SELECT get_trips_by_user(p_user_name:='Bill');
SELECT get_trips_by_user(p_user_name:='Jim');