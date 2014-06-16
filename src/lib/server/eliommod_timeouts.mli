(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2007 Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)
val set_default_service_timeout : [< Eliom_common.cookie_level ] -> float option -> unit
val set_default_data_timeout : [< Eliom_common.cookie_level ] -> float option -> unit
val set_default_persistent_timeout : [< Eliom_common.cookie_level ] -> float option -> unit
val get_default_service_timeout : [< Eliom_common.cookie_level ] -> float option
val get_default_data_timeout : [< Eliom_common.cookie_level ] -> float option
val get_default_persistent_timeout : [< Eliom_common.cookie_level ] -> float option
val set_default_volatile_timeout :  [< Eliom_common.cookie_level ] -> float option -> unit
val add : 'a -> 'b -> ('a * 'b) list -> ('a * 'b) list

val find_global_service_timeout :
  Eliom_common.full_state_name -> Eliom_common.sitedata -> float option
val find_global_data_timeout :
  Eliom_common.full_state_name -> Eliom_common.sitedata -> float option
val find_global_persistent_timeout :
  Eliom_common.full_state_name -> Eliom_common.sitedata -> float option

val get_global_service_timeout :
  cookie_scope:[< Eliom_common.cookie_scope ] ->
  secure:bool ->
  Eliom_common.sitedata -> float option
val get_global_data_timeout :
  cookie_scope:[< Eliom_common.cookie_scope ] ->
  secure:bool ->
  Eliom_common.sitedata -> float option
val get_global_persistent_timeout :
  cookie_scope:[< Eliom_common.cookie_scope ] ->
  secure:bool ->
  Eliom_common.sitedata -> float option

val set_global_service_timeout :
  cookie_scope:[< Eliom_common.cookie_scope ] ->
  secure:bool ->
  recompute_expdates:bool ->
  bool -> Eliom_common.sitedata -> float option -> unit
val set_global_data_timeout :
  cookie_scope:[< Eliom_common.cookie_scope ] ->
  secure:bool ->
  recompute_expdates:bool ->
  bool -> Eliom_common.sitedata -> float option -> unit
val set_global_persistent_timeout :
  cookie_scope:[< Eliom_common.cookie_scope ] ->
  secure:bool ->
  recompute_expdates:bool ->
  bool -> Eliom_common.sitedata -> float option -> unit

val set_global_service_timeout_ :
  ?full_st_name:Eliom_common.full_state_name ->
  ?cookie_level:[< Eliom_common.cookie_level ] ->
  recompute_expdates:bool ->
  bool ->
  bool -> Eliom_common.sitedata -> float option -> unit
val set_global_data_timeout_ :
  ?full_st_name:Eliom_common.full_state_name ->
  ?cookie_level:[< Eliom_common.cookie_level ] ->
  recompute_expdates:bool ->
  bool ->
  bool -> Eliom_common.sitedata -> float option -> unit
val set_global_persistent_timeout_ :
  ?full_st_name:Eliom_common.full_state_name ->
  ?cookie_level:[< Eliom_common.cookie_level ] ->
  recompute_expdates:bool ->
  bool ->
  bool -> Eliom_common.sitedata -> float option -> unit


val set_default_global_service_timeout :
  [< Eliom_common.cookie_level ] ->
  bool -> bool -> Eliom_common.sitedata -> float option -> unit
val set_default_global_data_timeout :
  [< Eliom_common.cookie_level ] ->
  bool -> bool -> Eliom_common.sitedata -> float option -> unit
val set_default_global_persistent_timeout :
  [< Eliom_common.cookie_level ] ->
  bool -> bool -> Eliom_common.sitedata -> float option -> unit
