public void GenerateJson()
{
	PrintToServer("%s 生成json文件中......", TAG_NCLR);
	g_fStart = GetEngineTime();
	char name[60],SectionName[100],item_name[300],index[7],num[6],line[300],models[100],econstr[60],buffer[10000],prefab[100];
	JSONObject jRoot = new JSONObject();
	JSONArray jWeapons = new JSONArray();
	JSONArray jGloves = new JSONArray();
	JSONArray jPaints = new JSONArray();
	JSONArray jPatches = new JSONArray();
	JSONArray jPins = new JSONArray();
	JSONArray jCrates = new JSONArray();
	JSONArray jMusicKits = new JSONArray();
	JSONArray jSprayes = new JSONArray();
	JSONArray Coincategories = new JSONArray();
	JSONArray CoinItems = new JSONArray();
	JSONObject jCoin = new JSONObject();
	JSONArray Stickercategories = new JSONArray();
	JSONArray StickerItems = new JSONArray();
	JSONObject jStickers = new JSONObject();
	ArrayList econ = new ArrayList(60);
	StringMap IndexbyName = new StringMap();
	StringMap cc = new StringMap();
	StringMap sc = new StringMap();
	StringMap wprefab = new StringMap();
	StringMap rare_draw = new StringMap();
	StringMap rare_ins = new StringMap();
	StringMap TransCN = ParseLanguage("schinese");
	StringMap TransEN = ParseLanguage("english");
	KeyValues kv = new KeyValues("items_game");
	int r_draw[][] = {{23,4},{63,7},{64,4},{517,1},{518,1},{519,1},{521,0},{525,1}};	//写死
	int r_ins[][] = {{1,8},{503,15},{512,13},{517,13},{518,13},{519,13},{521,0},{522,12},{523,15},{525,14}};	//写死
	for (int i = 0; i < sizeof(r_draw); i++)
	{
		IntToString(r_draw[i][0],num, sizeof(num));
		rare_draw.SetValue(num, r_draw[i][1]);
	}
	for (int i = 0; i < sizeof(r_ins); i++)
	{
		IntToString(r_ins[i][0],num, sizeof(num));
		rare_ins.SetValue(num, r_ins[i][1]);
	}
	kv.ImportFromFile("scripts/items/items_game.txt");
	kv.GotoFirstSubKey();
	do {
		kv.GetSectionName(SectionName, sizeof(SectionName));
		if (StrEqual(SectionName , "paint_kits"))
		{
			kv.SavePosition();
			kv.GotoFirstSubKey();
			do {
				kv.GetSectionName(index, sizeof(index));
				kv.GetString("name", name, sizeof(name));
				kv.GetString("description_tag", item_name, sizeof(item_name));
				StringToLow(name);
				StringToLow(item_name);
				IndexbyName.SetString(name, index);
				ReplaceStringEx(item_name, sizeof(item_name), "#", "");
				if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
					PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
				if (StrContains(name, "phase1") != -1)
					Format(item_name, sizeof(item_name), "%s (P1)", item_name);
				else if (StrContains(name, "phase2") != -1)
					Format(item_name, sizeof(item_name), "%s (P2)", item_name);
				else if (StrContains(name, "phase3") != -1)
					Format(item_name, sizeof(item_name), "%s (P3)", item_name);
				else if (StrContains(name, "phase4") != -1)
					Format(item_name, sizeof(item_name), "%s (P4)", item_name);
				else if (StrContains(name, "emerald_marbleized") != -1)
					Format(item_name, sizeof(item_name), "%s (绿宝石)", item_name);
				else if (StrContains(name, "ruby_marbleized") != -1)
					Format(item_name, sizeof(item_name), "%s (红宝石)", item_name);
				else if (StrContains(name, "sapphire_marbleized") != -1)
					Format(item_name, sizeof(item_name), "%s (蓝宝石)", item_name);
				else if (StrContains(name, "blackpearl_marbleized") != -1)
					Format(item_name, sizeof(item_name), "%s (黑珍珠)", item_name);
				else if (StrEqual(item_name, "-"))
					Format(item_name, sizeof(item_name), "默认");
				if (!StrEqual(index, "9001"))
				{
					JSONObject temp = new JSONObject();
					temp.SetInt("def_index", StringToInt(index));
					temp.SetString("item_name", item_name);
					jPaints.Push(temp);
					delete temp;
				}
			} while (kv.GotoNextKey());	
			kv.GoBack();
		}
		else if (StrEqual(SectionName , "sticker_kits"))
		{
			kv.SavePosition();
			kv.GotoFirstSubKey();
			do {
				kv.GetSectionName(index, sizeof(index));
				kv.GetString("item_name", item_name, sizeof(item_name));
				kv.GetString("name", name, sizeof(name));
				if (StrEqual(item_name, "default"))
					Format(item_name, sizeof(item_name), "Rarity_Default");
				if (StrContains(name, "graffiti") == -1 && StrContains(name, "spray") == -1)
				{
					StringToLow(item_name);
					ReplaceStringEx(item_name, sizeof(item_name), "#", "");
					JSONObject temp = new JSONObject();
					temp.SetInt("def_index", StringToInt(index));
					if (StrContains(item_name, "patchkit") != -1)
					{
						if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
							PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
						temp.SetString("item_name", item_name);
						jPatches.Push(temp);
						Format(item_name, sizeof(item_name), "%s (布章)", item_name);
						StickerItems.Push(temp);
					}
					else if (StrContains(item_name, "stickerkit") != -1)
					{
						if (StrEqual(item_name, "stickerkit_dhw2014_dignitas_gold"))
							item_name = "stickerkit_dhw2014_teamdignitas_gold";
						if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
							PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
						kv.GetString("patch_material", models, sizeof(models));
						if (!StrEqual(models, ""))
						{
							temp.SetString("item_name", item_name);
							jPatches.Push(temp);
							Format(item_name, sizeof(item_name), "%s (布章)", item_name);
							StickerItems.Push(temp);
						}
						else
						{
							kv.GetString("sticker_material", models, sizeof(models));
							if (!StrEqual(models, ""))
							{
								char split[2][64], evenid[10];
								kv.GetString("tournament_event_id", evenid, sizeof(evenid));
								if (!StrEqual(evenid, ""))
								{
									Format(split[0], sizeof(split[]), "csgo_tournament_event_nameshort_%s", evenid);
									TransData(split[0], sizeof(split[]), TransCN, TransEN);
								}
								else
								{
									ExplodeString(models, "/", split, sizeof(split), sizeof(split[]));
									if (StrEqual(split[0], "standard"))
										split[0] = "印花胶囊 1号印花";
									else if (StrEqual(split[0], "stickers2"))
										split[0] = "印花胶囊 2号印花";
									else if (StrEqual(split[0], "tournament_assets"))
										split[0] = "锦标赛资产";
									else if (StrEqual(split[0], "community02"))
										split[0] = "2号社区印花";
									else if (StrEqual(split[0], "danger_zone"))
										split[0] = "头号特训";
									else if (StrEqual(split[0], "alyx"))
										split[0] = "《半衰期：爱莉克斯》印花胶囊";
									else
									{
										StringToLow(split[0]);
										if(!TransData(split[0], sizeof(split[]), TransCN, TransEN))
										{
											Format(split[0], sizeof(split[]), "csgo_crate_sticker_pack_%s", split[0]);
											if(!TransData(split[0], sizeof(split[]), TransCN, TransEN))
											{
												Format(split[0], sizeof(split[]), "%s_capsule", split[0]);
												TransData(split[0], sizeof(split[]), TransCN, TransEN);
											}
										}
									}
								}
								if (sc.GetString(split[0], buffer, sizeof(buffer)))
									Format(buffer, sizeof(buffer), "%s,%s", buffer, index);
								else
									Format(buffer, sizeof(buffer), "%s", index);
								sc.SetString(split[0], buffer);
								temp.SetString("item_name", item_name);
								StickerItems.Push(temp);
							}
						}
					}
					delete temp;
				}
				else
				{
					kv.GetString("item_name", item_name, sizeof(item_name));
					kv.GetString("sticker_material", models, sizeof(models));
					StringToLow(item_name);
					ReplaceStringEx(item_name, sizeof(item_name), "#", "");
					if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
						PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
					JSONObject jTemp = new JSONObject();
					jTemp.SetInt("def_index", StringToInt(index));
					jTemp.SetString("item_name", item_name);
					jTemp.SetString("material", models);
					jSprayes.Push(jTemp);
					delete jTemp;
				}
			} while (kv.GotoNextKey());	
			kv.GoBack();
		}
		else if (StrEqual(SectionName , "music_definitions"))
		{
			kv.SavePosition();
			kv.GotoFirstSubKey();
			do {
				kv.GetSectionName(index, sizeof(index));
				kv.GetString("loc_name", item_name, sizeof(item_name));
				StringToLow(item_name);
				ReplaceStringEx(item_name, sizeof(item_name), "#", "");
				if (!StrEqual(item_name, "musickit_valve_csgo_02"))
				{
					if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
						PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
					if (StrEqual(item_name, "CS:GO"))
						Format(item_name, sizeof(item_name), "CSGO默认音乐盒");
					JSONObject temp = new JSONObject();
					temp.SetInt("def_index", StringToInt(index));
					temp.SetString("item_name", item_name);
					jMusicKits.Push(temp);
					delete temp;
				}
			} while (kv.GotoNextKey());	
			kv.GoBack();
		}
		else if (StrEqual(SectionName , "items"))
		{
			kv.SavePosition();
			kv.GotoFirstSubKey();
			do {
				kv.GetSectionName(index, sizeof(index));
				kv.GetString("model_player", models, sizeof(models));
				if (StringToInt(index) > 0 && StringToInt(index) < 800)
				{
					kv.GetString("name", name, sizeof(name));
					kv.GetString("prefab", prefab, sizeof(prefab));
					if (!StrEqual(prefab, "equipment") && !StrEqual(prefab, "recipe") && !StrEqual(prefab, "musickit_prefab") && !StrEqual(name, "weapon_melee") && !StrEqual(name, "weapon_knife_ghost"))
					{
						JSONObject jTemp = new JSONObject();
						jTemp.SetInt("def_index", StringToInt(index));
						jTemp.SetString("class_name", name);
						Format(name, sizeof(name), "%s_prefab", name);
						if (!StrEqual(prefab, name))
						{
							kv.GetString("item_name", item_name, sizeof(item_name));
							StringToLow(item_name);
							ReplaceStringEx(item_name, sizeof(item_name), "#", "");
							if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
								PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
							jTemp.SetString("item_name", item_name);
							if (StrEqual(prefab, "melee_unusual") || StrContains(name, "knife") != -1)
								jTemp.SetInt("slot", 2);
							kv.GetString("model_player", models, sizeof(models));
							jTemp.SetString("view_model", models);
							kv.GetString("model_world", models, sizeof(models));
							jTemp.SetString("world_model", models);
							kv.GetString("model_dropped", models, sizeof(models));
							if (StrEqual(models, ""))
								jTemp.SetNull("dropped_model");
							else
								jTemp.SetString("dropped_model", models);
							jTemp.SetNull("stickers_count");
							jTemp.SetInt("team", 0);
							int value;
							if (rare_draw.GetValue(index, value))
							{
								jTemp.SetBool("has_rare_draw", true);
								jTemp.SetInt("rare_draw", value);
							}
							else
								jTemp.SetBool("has_rare_draw", false);
							if (rare_ins.GetValue(index, value))
							{
								jTemp.SetBool("has_rare_inspect", true);
								jTemp.SetInt("rare_inspect", value);
							}
							else
								jTemp.SetBool("has_rare_inspect", false);
						}
						else
							wprefab.SetValue(prefab, jWeapons.Length);
						jWeapons.Push(jTemp);
						delete jTemp;
					}
				}
				if (StrContains(models, "models/weapons/v_models/arms/") != -1)
				{
					kv.GetString("item_name", item_name, sizeof(item_name));
					StringToLow(item_name);
					ReplaceStringEx(item_name, sizeof(item_name), "#", "");
					if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
						PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
					kv.GetString("name", name, sizeof(name));
					JSONObject jTemp = new JSONObject();
					jTemp.SetInt("def_index", StringToInt(index));
					jTemp.SetString("item_name", item_name);
					jTemp.SetString("class_name", name);
					jTemp.SetString("view_model", models);
					kv.GetString("model_world", models, sizeof(models));
					jTemp.SetString("world_model", models);
					if (!StrEqual(name, "t_gloves") && !StrEqual(name, "ct_gloves"))
						jGloves.Push(jTemp);
					delete jTemp;
				}
				kv.GetString("prefab", models, sizeof(models));
				if (StrEqual(models, "commodity_pin"))
				{
					kv.GetString("item_name", item_name, sizeof(item_name));
					StringToLow(item_name);
					ReplaceStringEx(item_name, sizeof(item_name), "#", "");
					if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
						PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
					JSONObject jTemp = new JSONObject();
					jTemp.SetInt("def_index", StringToInt(index));
					jTemp.SetString("item_name", item_name);
					jPins.Push(jTemp);
					delete jTemp;
				}
				if (StrEqual(models, "weapon_case"))
				{
					kv.GetString("model_player", models, sizeof(models));
					kv.GetString("item_name", item_name, sizeof(item_name));
					StringToLow(item_name);
					ReplaceStringEx(item_name, sizeof(item_name), "#", "");
					if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
						PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
					JSONObject jTemp = new JSONObject();
					jTemp.SetInt("def_index", StringToInt(index));
					jTemp.SetString("item_name", item_name);
					jTemp.SetString("view_model", models);
					jCrates.Push(jTemp);
					delete jTemp;
				}
				if (StrEqual(models, "collectible_untradable"))
				{
					kv.GetString("item_name", item_name, sizeof(item_name));
					if (!StrEqual(item_name, ""))
					{
						StringToLow(item_name);
						ReplaceStringEx(item_name, sizeof(item_name), "#", "");
						if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
							PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
						JSONObject jTemp = new JSONObject();
						jTemp.SetInt("def_index", StringToInt(index));
						jTemp.SetString("item_name", item_name);
						CoinItems.Push(jTemp);
						delete jTemp;
						if (kv.GotoFirstSubKey())
						{
							if (kv.GotoFirstSubKey())
							{
								kv.GetString("value", num, sizeof(num));
								Format(models, sizeof(models), "csgo_tournament_event_nameshort_%s", num);
								TransData(models, sizeof(models), TransCN, TransEN);
								kv.GoBack();
							}
							else
								models = "Valve";
							kv.GoBack();
						}
						else
							models = "Valve";
						if (cc.GetString(models, buffer, sizeof(buffer)))
							Format(buffer, sizeof(buffer), "%s,%s", buffer, index);
						else
							Format(buffer, sizeof(buffer), "%s", index);
						cc.SetString(models, buffer);
					}
				}
				if (StrContains(models, "season") != -1 || StrEqual(models, "map_token") || StrEqual(models, "prestige_coin"))
				{
					kv.GetString("item_name", item_name, sizeof(item_name));
					StringToLow(item_name);
					ReplaceStringEx(item_name, sizeof(item_name), "#", "");
					if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
						PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
					JSONObject jTemp = new JSONObject();
					jTemp.SetInt("def_index", StringToInt(index));
					jTemp.SetString("item_name", item_name);
					CoinItems.Push(jTemp);
					delete jTemp;
					if(cc.GetString("Valve", buffer, sizeof(buffer)))
					Format(buffer, sizeof(buffer), "%s,%s", buffer, index);
					cc.SetString("Valve", buffer);
				}
			} while (kv.GotoNextKey());	
			kv.GoBack();
		}
	} while (kv.GotoNextKey());
	kv.Rewind();
	kv.JumpToKey("prefabs");
	for (int i = 0; i < wprefab.Size; i++)
	{
		wprefab.Snapshot().GetKey(i, prefab, sizeof(prefab));
		if (kv.JumpToKey(prefab))
		{
			int v;
			wprefab.GetValue(prefab, v);
			JSONObject jTemp = view_as<JSONObject>(jWeapons.Get(v));
			kv.GetString("prefab", prefab, sizeof(prefab));
			kv.GetString("item_name", item_name, sizeof(item_name));
			StringToLow(item_name);
			ReplaceStringEx(item_name, sizeof(item_name), "#", "");
			if (!TransData(item_name, sizeof(item_name), TransCN, TransEN))
				PrintToServer("%s 未找到翻译(%s)", TAG_NCLR, item_name);
			jTemp.SetString("item_name", item_name);
			if (StrContains(prefab, "gun") != -1 || StrContains(prefab, "rifle") != -1 || StrEqual(prefab, "smg") || StrEqual(prefab, "primary"))
				jTemp.SetInt("slot", 0);
			if (StrEqual(prefab, "secondary"))
				jTemp.SetInt("slot", 1);
			if (StrContains(prefab, "knife") != -1)
				jTemp.SetInt("slot", 2);
			kv.GetString("model_player", models, sizeof(models));
			jTemp.SetString("view_model", models);
			kv.GetString("model_world", models, sizeof(models));
			jTemp.SetString("world_model", models);
			kv.GetString("model_dropped", models, sizeof(models));
			if (StrEqual(models, ""))
				jTemp.SetNull("dropped_model");
			else
				jTemp.SetString("dropped_model", models);
			if (kv.JumpToKey("stickers"))
			{
				int stickers_count = -1;
				while (kv.GotoNextKey())
					stickers_count++;
				jTemp.SetInt("stickers_count", stickers_count);
				kv.GoBack();
			}
			else
				jTemp.SetNull("stickers_count");
			if (kv.JumpToKey("used_by_classes"))
			{
				char cteam[5];
				kv.GetString("terrorists", models, sizeof(models));
				kv.GetString("counter-terrorists", cteam, sizeof(cteam));
				if (StrEqual(models, "1") && StrEqual(cteam, "1"))
					jTemp.SetInt("team", 0);
				else if (StrEqual(models, "1"))
					jTemp.SetInt("team", 2);
				else if (StrEqual(cteam, "1"))
					jTemp.SetInt("team", 3);
				kv.GoBack();
			}
			else
				jTemp.SetInt("team", 0);
			Format(index, sizeof(index), "%d", jTemp.GetInt("def_index"));
			int value;
			if (rare_draw.GetValue(index, value))
			{
				jTemp.SetBool("has_rare_draw", true);
				jTemp.SetInt("rare_draw", value);
			}
			else
				jTemp.SetBool("has_rare_draw", false);
			if (rare_ins.GetValue(index, value))
			{
				jTemp.SetBool("has_rare_inspect", true);
				jTemp.SetInt("rare_inspect", value);
			}
			else
				jTemp.SetBool("has_rare_inspect", false);
			if (kv.JumpToKey("attributes"))
			{
				if (kv.GotoFirstSubKey(false))
				{
					JSONObject jAttr = new JSONObject();
					do {
						kv.GetSectionName(SectionName, sizeof(SectionName));
						kv.GetString(NULL_STRING, models, sizeof(models));
						jAttr.SetString(SectionName, models);
					} while (kv.GotoNextKey(false));
					jTemp.Set("attributes", jAttr);
					delete jAttr;
					kv.GoBack();
				}
				kv.GoBack();
			}
			jWeapons.Set(v, jTemp);
			delete jTemp;
			kv.GoBack();
		}
	}	
	delete kv;
	for (int i = 0; i <= sc.Size; i++)
	{
		char key[64], split[600][6];
		JSONObject jTemp = new JSONObject();
		JSONObject items = new JSONObject();
		if (i != sc.Size)
		{
			sc.Snapshot().GetKey(i, key, sizeof(key));
			sc.GetString(key, buffer, sizeof(buffer));
			jTemp.SetInt("id", i);
			jTemp.SetString("name", key);
			int size = ExplodeString(buffer, ",", split, sizeof(split), sizeof(split[]));
			for (int j = 0; j < size; j++)
			{
				IntToString(j, num, sizeof(num));
				items.SetInt(num, StringToInt(split[j]));
			}
		}
		else
		{
			jTemp.SetInt("id", sc.Size);
			jTemp.SetString("name", "CSGO布章");
			for (int j = 0; j < jPatches.Length; j++)
			{
				IntToString(j, num, sizeof(num));
				JSONObject jp = view_as<JSONObject>(jPatches.Get(j));
				items.SetInt(num, jp.GetInt("def_index"));
				delete jp;
			}
		}
		jTemp.Set("items", items);
		delete items;
		Stickercategories.Push(jTemp);
		delete jTemp;
	}
	jStickers.Set("categories", Stickercategories);
	jStickers.Set("items", StickerItems);
	delete Stickercategories;
	delete StickerItems;
	for (int i = 0; i < cc.Size; i++)
	{
		char key[64], split[600][6];
		JSONObject jTemp = new JSONObject();
		JSONObject items = new JSONObject();
		cc.Snapshot().GetKey(i, key, sizeof(key));
		cc.GetString(key, buffer, sizeof(buffer));
		jTemp.SetInt("id", i);
		jTemp.SetString("name", key);
		int size = ExplodeString(buffer, ",", split, sizeof(split), sizeof(split[]));
		for (int j = 0; j < size; j++)
		{
			IntToString(j, num, sizeof(num));
			items.SetInt(num, StringToInt(split[j]));
		}
		jTemp.Set("items", items);
		delete items;
		Coincategories.Push(jTemp);
		delete jTemp;
	}
	jCoin.Set("categories", Coincategories);
	jCoin.Set("items", CoinItems);
	delete Stickercategories;
	delete StickerItems;
	File file = OpenFile("scripts/items/items_game.txt", "r");
	Regex reg = new Regex("\\s+\"icon_path\"\\s+\"econ/default_generated/(.+)_light\"");
	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (reg.Match(line) == 2)
		{
			reg.GetSubString(1, econstr, sizeof(econstr));
			StringToLow(econstr);
			econ.PushString(econstr);
		}	
	}
	delete reg;
	delete file;
	for (int i = 0; i < jWeapons.Length; i++)
	{
		JSONObject jTemp = view_as<JSONObject>(jWeapons.Get(i));
		jTemp.Remove("paints");
		jTemp.GetString("class_name", name, sizeof(name));
		if (!StrEqual(name, "weapon_knife") && !StrEqual(name, "weapon_knifegg"))
		{
			Format(name, sizeof(name), "%s_", name);
			for (int j = 0; j < econ.Length; j++)
			{
				econ.GetString(j, econstr, sizeof(econstr));
				if (StrContains(econstr, name) != -1)
				{
					ReplaceString(econstr, sizeof(econstr), name, "");
					IndexbyName.GetString(econstr, index, sizeof(index));
					JSONObject paints = new JSONObject();
					if (!jTemp.HasKey("paints"))
						paints.SetString("0", index);
					else
					{
						paints = view_as<JSONObject>(jTemp.Get("paints"));
						IntToString(paints.Size, num, sizeof(num));
						paints.SetInt(num, StringToInt(index));
					}
					jTemp.Set("paints", paints);
					delete paints;
				}
				jWeapons.Set(i, jTemp);
			}
		}
		delete jTemp;
	}
	for (int i = 0; i < jGloves.Length; i++)
	{
		JSONObject jTemp = view_as<JSONObject>(jGloves.Get(i));
		jTemp.GetString("class_name", name, sizeof(name));
		Format(name, sizeof(name), "%s_", name);
		StringToLow(name);
		for (int j = 0; j < econ.Length; j++)
		{
			econ.GetString(j, econstr, sizeof(econstr));
			if (StrContains(econstr, name) != -1)
			{
				ReplaceString(econstr, sizeof(econstr), name, "");
				IndexbyName.GetString(econstr, index, sizeof(index));
				JSONObject paints = new JSONObject();
				if (!jTemp.HasKey("paints"))
					paints.SetString("0", index);
				else
				{
					paints = view_as<JSONObject>(jTemp.Get("paints"));
					IntToString(paints.Size, num, sizeof(num));
					paints.SetInt(num, StringToInt(index));
				}
				jTemp.Set("paints", paints);
				delete paints;
			}
			jGloves.Set(i, jTemp);
		}
		delete jTemp;
	}
	delete econ;
	jRoot.Set("weapons", jWeapons);
	jRoot.Set("paints", jPaints);
	jRoot.Set("gloves", jGloves);
	jRoot.Set("coins", jCoin);
	jRoot.Set("pins", jPins);
	jRoot.Set("crates", jCrates);
	jRoot.Set("music_kits", jMusicKits);
	jRoot.Set("patches", jPatches);
	jRoot.Set("sprayes", jSprayes);
	jRoot.Set("stickers", jStickers);
	jRoot.SetInt("Lastest", GetTime());
	jRoot.ToFile("addons/sourcemod/data/eItems/eItems.json", 4);
	delete jRoot;
	delete cc;
	delete sc;
	delete jWeapons;
	delete jPatches;
	delete jPaints;
	delete jCrates;
	delete jCoin;
	delete jPins;
	delete jGloves;
	delete jMusicKits;
	delete jSprayes;
	delete jStickers;
	float fEnd = GetEngineTime();
	PrintToServer("%s json文件生成成功！花费%0.5f秒", TAG_NCLR, fEnd - g_fStart);
	ParseItems();
}

public StringMap ParseLanguage(const char[] language)
{
	char Path[100];
	Format(Path, sizeof(Path), "resource/csgo_%s.txt", language);
	File file = OpenFile(Path, "r");
	StringMap lang = new StringMap();
	Regex reg = new Regex("\"(.+)\"\\s+\"(.+)\"");
	int data, i = 0, high_surrogate, low_surrogate;
	char line[4096],token[128], value[1024];
	while(ReadFileCell(file, data, 2) == 1) {
		if( high_surrogate ) 
		{
			low_surrogate = data;
			data = ((high_surrogate - 0xD800) << 10) + (low_surrogate - 0xDC00) + 0x10000;
			line[i++] = ((data >> 18) & 0x07) | 0xF0;
			line[i++] = ((data >> 12) & 0x3F) | 0x80;
			line[i++] = ((data >> 6) & 0x3F) | 0x80;
			line[i++] = (data & 0x3F) | 0x80;
			high_surrogate = 0;
		}
		else if(data < 0x80) 
		{
			line[i++] = data;
			if(data == '\n') 
			{
				line[i] = '\0';
				if (reg.Match(line) == 3)
				{
					reg.GetSubString(1, token, sizeof(token));
					reg.GetSubString(2, value, sizeof(value));
					StringToLow(token);
					lang.SetString(token, value);
				}
				i = 0;
			}
		}
		else if(data < 0x800) 
		{
			line[i++] = ((data >> 6) & 0x1F) | 0xC0;
			line[i++] = (data & 0x3F) | 0x80;
		} 
		else if(data <= 0xFFFF) 
		{
			if(0xD800 <= data <= 0xDFFF) 
			{
				high_surrogate = data;
				continue;
			}
			line[i++] = ((data >> 12) & 0x0F) | 0xE0;
			line[i++] = ((data >> 6) & 0x3F) | 0x80;
			line[i++] = (data & 0x3F) | 0x80;
		}
	}
	delete file;
	return lang;
}
