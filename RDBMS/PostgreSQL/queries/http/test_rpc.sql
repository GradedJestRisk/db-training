SELECT hello_over_network();

SELECT hello_over_network(p_user_id := 1, p_email := 'foo@bar.com');

--SELECT jsonb_pretty(hello_over_network()::jsonb);