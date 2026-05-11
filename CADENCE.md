# Cadence — Documentação do Projeto

## Conceito
Rede social musical — mistura de Letterboxd + Last.fm + Tumblr + MySpace.
Foco em identidade musical, comunidade, estética e descoberta.
**Filosofia:** transformar gosto musical em identidade social.

O app NÃO deve virar um "Twitter genérico". Toda interação deve ser centrada em música.

## Linguagem da Plataforma
Reproduções musicais são chamadas de **Cadences** (não "scrobbles").
- "500 cadences essa semana"
- "most cadenced artist"
- "daily cadence"
- "cadence streak"

---

## Referências
- Letterboxd — reviews, listas, feed social
- Last.fm — tracking, rankings, stats
- Tumblr / MySpace / SpaceHey — estética, perfis personalizados, internet dos anos 2000
- Spotify Wrapped — shareables visuais
- Airbuds — currently playing social

---

## Stack
- **Backend:** Java + Javalin
- **Banco:** PostgreSQL
- **Frontend:** React
- **Integrações:** Spotify API, Last.fm API
- **Auth:** JWT
- **Dev:** Linux Fedora + Hyprland

---

## Banco de Dados

### users
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| username | VARCHAR | único |
| email | VARCHAR | único |
| password_hash | VARCHAR | |
| bio | TEXT | |
| avatar_url | VARCHAR | |
| profile_bg_color | VARCHAR | hex |
| profile_accent_color | VARCHAR | hex |
| profile_font | VARCHAR | |
| profile_theme | VARCHAR | tema pré-definido |
| profile_banner_url | VARCHAR | |
| profile_cursor | VARCHAR | cursor customizado |
| current_era | VARCHAR | ex: "fase shoegaze" |
| spotify_id | VARCHAR | |
| spotify_access_token | TEXT | |
| spotify_refresh_token | TEXT | |
| lastfm_username | VARCHAR | |
| lastfm_session_key | VARCHAR | |
| is_premium | BOOLEAN | |
| created_at | TIMESTAMP | |

### albums
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| spotify_id | VARCHAR | único |
| name | VARCHAR | |
| artist_name | VARCHAR | |
| cover_url | VARCHAR | |
| release_year | INT | |
| genres | VARCHAR[] | |

### reviews
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK users |
| album_id | UUID | FK albums |
| rating | DECIMAL | 0.5 a 5.0 |
| body | TEXT | opcional |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | |

### album_status
| campo | tipo | descrição |
|---|---|---|
| user_id | UUID | FK users |
| album_id | UUID | FK albums |
| status | ENUM | LISTENED, WANT_TO_LISTEN |
| updated_at | TIMESTAMP | |

### scrobbles
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK users |
| track_name | VARCHAR | |
| album_name | VARCHAR | |
| artist_name | VARCHAR | |
| spotify_track_id | VARCHAR | nullable |
| played_at | TIMESTAMP | |

### follows
| campo | tipo | descrição |
|---|---|---|
| follower_id | UUID | FK users |
| following_id | UUID | FK users |
| created_at | TIMESTAMP | |

### posts
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK users |
| body | TEXT | opcional |
| track_id | VARCHAR | spotify track id, opcional |
| album_id | UUID | FK albums, opcional |
| post_type | ENUM | REVIEW, TRACK, MOOD, RANKING |
| parent_id | UUID | FK posts, pra quote repost |
| created_at | TIMESTAMP | |

### post_interactions
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| post_id | UUID | FK posts |
| user_id | UUID | FK users |
| type | ENUM | LIKE, REPOST, COMMENT |
| body | TEXT | só pra COMMENT |
| created_at | TIMESTAMP | |

### profile_widgets
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK users |
| widget_type | ENUM | NOW_PLAYING, TOP_ARTISTS, TOP_ALBUMS, ERA, BADGE, COMPATIBILITY, QUOTE, GIF |
| position_x | INT | |
| position_y | INT | |
| config | JSONB | configurações específicas do widget |

### badges
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK users |
| type | ENUM | TOP_LISTENER, EARLY_LISTENER, VETERAN_FAN, CROWN |
| artist_name | VARCHAR | |
| earned_at | TIMESTAMP | |

### listen_sessions
| campo | tipo | descrição |
|---|---|---|
| id | UUID | PK |
| host_id | UUID | FK users |
| spotify_context_uri | VARCHAR | |
| started_at | TIMESTAMP | |
| ended_at | TIMESTAMP | nullable |

### listen_session_members
| campo | tipo | descrição |
|---|---|---|
| session_id | UUID | FK listen_sessions |
| user_id | UUID | FK users |
| joined_at | TIMESTAMP | |

---

## Rotas da API

### Auth — `/api/auth`
| método | rota | descrição |
|---|---|---|
| POST | `/register` | cria conta |
| POST | `/login` | retorna JWT |
| POST | `/spotify/connect` | OAuth Spotify |
| POST | `/lastfm/connect` | OAuth Last.fm |
| POST | `/refresh` | renova JWT |

### Users — `/api/users`
| método | rota | descrição |
|---|---|---|
| GET | `/:username` | perfil público |
| PUT | `/me` | edita perfil |
| GET | `/me/feed` | feed de atividades |
| GET | `/me/currently-playing` | faixa atual do Spotify |
| GET | `/:username/reviews` | reviews do usuário |
| GET | `/:username/scrobbles` | histórico de cadences |
| GET | `/:username/top` | top artistas/álbuns |
| GET | `/:username/widgets` | widgets do perfil |
| PUT | `/me/widgets` | atualiza widgets |

### Follows — `/api/follows`
| método | rota | descrição |
|---|---|---|
| POST | `/:username` | seguir |
| DELETE | `/:username` | deixar de seguir |
| GET | `/:username/followers` | lista seguidores |
| GET | `/:username/following` | lista seguindo |

### Albums — `/api/albums`
| método | rota | descrição |
|---|---|---|
| GET | `/search?q=` | busca via Spotify |
| GET | `/:spotifyId` | detalhes do álbum |
| POST | `/:spotifyId/review` | criar/atualizar review |
| DELETE | `/:spotifyId/review` | deletar review |
| POST | `/:spotifyId/status` | marcar ouvido/quero ouvir |

### Posts — `/api/posts`
| método | rota | descrição |
|---|---|---|
| POST | `/` | criar post |
| GET | `/:id` | ver post |
| DELETE | `/:id` | deletar post |
| POST | `/:id/like` | curtir |
| DELETE | `/:id/like` | descurtir |
| POST | `/:id/repost` | repostar |
| POST | `/:id/comment` | comentar |

### Rankings — `/api/rankings`
| método | rota | descrição |
|---|---|---|
| GET | `/artist/:name` | ranking global de fãs |
| GET | `/artist/:name/br` | ranking BR |
| GET | `/me/positions` | minhas posições em rankings |

### Listen Sessions — `/api/sessions`
| método | rota | descrição |
|---|---|---|
| POST | `/` | criar sessão |
| POST | `/:id/join` | entrar (requer Spotify Premium) |
| DELETE | `/:id/leave` | sair |
| GET | `/:id` | estado atual |

### Shareables — `/api/shareables`
| método | rota | descrição |
|---|---|---|
| GET | `/me/wrapped?period=month` | recap mensal |
| GET | `/me/top-artists` | imagem top artistas |
| GET | `/compatibility/:username` | compatibilidade |

---

## Perfil Customizável
Sistema controlado — sem HTML/CSS livre (segurança, XSS, mobile).

**Customizações:**
- temas pré-definidos
- cor de fundo e accent
- fonte
- banner
- cursor customizado
- stickers / gifs
- widgets arrastáveis

**Widgets disponíveis:**
- currently playing
- top artistas / álbuns
- álbum da semana
- quote musical
- badges
- era musical atual
- compatibilidade musical
- gif favorito
- ranking de fã

---

## Roadmap

### MVP (v1)
- [ ] Auth (registro, login, JWT)
- [ ] OAuth Spotify + Last.fm
- [ ] Perfil customizável básico
- [ ] Currently playing
- [ ] Busca e review de álbuns
- [ ] Cadences (histórico do Last.fm)
- [ ] Seguir pessoas
- [ ] Feed básico

### v2
- [ ] Posts musicais
- [ ] Curtidas, comentários, reposts
- [ ] Ranking de fãs (global e BR)
- [ ] Badges
- [ ] Eras musicais
- [ ] Widgets arrastáveis
- [ ] Ouvir junto (listen session)

### v3
- [ ] Compatibilidade musical
- [ ] Rivals
- [ ] Shareables visuais
- [ ] Recap mensal
- [ ] Premium
- [ ] IA musical

---

## Notas
- Albums são cache local de dados do Spotify
- Ranking calculado via contagem de cadences por artista
- Listen session requer Spotify Premium nos dois lados — avisar no botão
- Posts devem ser centrados em música — sem texto solto puro no MVP
- Beta fechado por convite no lançamento
- Crescimento orgânico via shareables e estética dos perfis
