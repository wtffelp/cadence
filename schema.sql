CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUM types
CREATE TYPE album_status_enum AS ENUM ('LISTENED', 'WANT_TO_LISTEN');
CREATE TYPE post_type_enum AS ENUM ('REVIEW', 'TRACK', 'MOOD', 'RANKING');
CREATE TYPE interaction_type_enum AS ENUM ('LIKE', 'REPOST', 'COMMENT');
CREATE TYPE badge_type_enum AS ENUM ('TOP_LISTENER', 'EARLY_LISTENER', 'VETERAN_FAN', 'CROWN');
CREATE TYPE widget_type_enum AS ENUM ('NOW_PLAYING', 'TOP_ARTISTS', 'TOP_ALBUMS', 'ERA', 'BADGE', 'COMPATIBILITY', 'QUOTE', 'GIF');

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    profile_bg_color VARCHAR(7) DEFAULT '#000000',
    profile_accent_color VARCHAR(7) DEFAULT '#ffffff',
    profile_font VARCHAR(100),
    profile_theme VARCHAR(100),
    profile_banner_url VARCHAR(500),
    profile_cursor VARCHAR(100),
    current_era VARCHAR(100),
    spotify_id VARCHAR(100),
    spotify_access_token TEXT,
    spotify_refresh_token TEXT,
    lastfm_username VARCHAR(100),
    lastfm_session_key VARCHAR(255),
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Albums (cache do Spotify)
CREATE TABLE albums (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    spotify_id VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    artist_name VARCHAR(255) NOT NULL,
    cover_url VARCHAR(500),
    release_year INT,
    genres VARCHAR(100)[]
);

-- Reviews
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
    rating DECIMAL(2,1) CHECK (rating >= 0.5 AND rating <= 5.0),
    body TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, album_id)
);

-- Album status
CREATE TABLE album_status (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
    status album_status_enum NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, album_id)
);

-- Scrobbles (cadences)
CREATE TABLE scrobbles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_name VARCHAR(255) NOT NULL,
    album_name VARCHAR(255),
    artist_name VARCHAR(255) NOT NULL,
    spotify_track_id VARCHAR(100),
    played_at TIMESTAMP NOT NULL
);

-- Follows
CREATE TABLE follows (
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id)
);

-- Posts
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT,
    track_id VARCHAR(100),
    album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
    post_type post_type_enum NOT NULL,
    parent_id UUID REFERENCES posts(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Post interactions
CREATE TABLE post_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type interaction_type_enum NOT NULL,
    body TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(post_id, user_id, type)
);

-- Profile widgets
CREATE TABLE profile_widgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    widget_type widget_type_enum NOT NULL,
    position_x INT DEFAULT 0,
    position_y INT DEFAULT 0,
    config JSONB
);

-- Badges
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type badge_type_enum NOT NULL,
    artist_name VARCHAR(255),
    earned_at TIMESTAMP DEFAULT NOW()
);

-- Listen sessions
CREATE TABLE listen_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    spotify_context_uri VARCHAR(255),
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP
);

-- Listen session members
CREATE TABLE listen_session_members (
    session_id UUID NOT NULL REFERENCES listen_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (session_id, user_id)
);

-- Indexes
CREATE INDEX idx_scrobbles_user_id ON scrobbles(user_id);
CREATE INDEX idx_scrobbles_played_at ON scrobbles(played_at);
CREATE INDEX idx_scrobbles_artist ON scrobbles(artist_name);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
