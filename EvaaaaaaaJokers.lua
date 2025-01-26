--- STEAMODDED HEADER
--- MOD_NAME: EvaJokers
--- MOD_ID: EvaJokers
--- PREFIX: eva
--- MOD_AUTHOR: [Evidence02]
--- MOD_DESCRIPTION: [Bunch of Jokers and stuff?]
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: c7638f
--- VERSION: 0.0.1

----------------------------------------------
------------MOD CODE -------------------------

local enhancements = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_wild, G.P_CENTERS.m_glass, G.P_CENTERS.m_steel, G.P_CENTERS.m_stone, G.P_CENTERS.m_gold, G.P_CENTERS.m_lucky }

local function get_random_card(seed)
	local valid_cards = {}
	for k, v in ipairs(G.playing_cards) do
		if v.ability.effect ~= 'Stone Card' then
			valid_cards[#valid_cards+1] = v
		end
	end
	if valid_cards[1] then 
		return pseudorandom_element(valid_cards, pseudoseed(seed)) 
	end
end

local function get_random_enhancement(seed)
	return pseudorandom_element(enhancements, pseudoseed(seed))
end

local function get_random_seal(seed)
	return pseudorandom_element({ 'Red', 'Blue', 'Purple', 'Gold' }, pseudoseed(seed))
end

-- TODO: get tag list from game
local function get_random_tag(seed)
	local list_tags = { 'tag_uncommon', 'tag_rare', 'tag_negative', 'tag_foil', 'tag_holo', 'tag_polychrome', 'tag_investment', 'tag_voucher', 'tag_boss', 'tag_standard', 'tag_charm', 'tag_meteor', 'tag_buffoon', 'tag_handy', 'tag_garbage', 'tag_ethereal', 'tag_coupon', 'tag_double', 'tag_juggle', 'tag_d_six', 'tag_top_up', 'tag_skip', 'tag_orbital', 'tag_economy' }
	return pseudorandom_element(list_tags, pseudoseed('j_eva_tagged'))
	
	--local temp_tag = pseudorandom_element(G.GAME.tags, pseudoseed('j_eva_tagged'))
	--return temp_tag.name
end



local function rank_to_string(r)
		if r <  10 then return tostring(r)
	elseif r == 10 then return 'T'
	elseif r == 11 then return 'J'
	elseif r == 12 then return 'Q'
	elseif r == 13 then return 'K'
	elseif r == 14 then return 'A'
	end
end

local function rank_short(r)
		if r <  10 then return tostring(r)
	elseif r == 10 then return '10'
	elseif r == 11 then return 'J'
	elseif r == 12 then return 'Q'
	elseif r == 13 then return 'K'
	elseif r == 14 then return 'A'
	end
end

local function rank_name(r)
		if r <= 10 then return tostring(r)
	elseif r == 11 then return 'Jack'
	elseif r == 12 then return 'Queen'
	elseif r == 13 then return 'King'
	elseif r == 14 then return 'Ace'
	end
end

local function card_description(card)
	return rank_name(card.base.id) ..' of '.. card.base.suit
end

local function copy_card_and_add_to_hand(card)
	local _card = copy_card(card, nil, nil, G.playing_card)
	_card:add_to_deck()
	G.deck.config.card_limit = G.deck.config.card_limit + 1
	table.insert(G.playing_cards, _card)
	G.hand:emplace(_card)
	_card.states.visible = nil
	G.E_MANAGER:add_event(Event({
		func = function()
			_card:start_materialize()
			return true
		end
	})) 
end

local function copy_and_reroll_card(card, base)
	local _card = copy_card(card, nil, nil, G.playing_card)
	_card:set_base(base)
	_card:add_to_deck()
	G.deck.config.card_limit = G.deck.config.card_limit + 1
	table.insert(G.playing_cards, _card)
	G.hand:emplace(_card)
	_card.states.visible = nil
	G.E_MANAGER:add_event(Event({
		func = function()
			_card:start_materialize()
			return true
		end
	})) 
end


local function recalculate_fulldeck_jokers()
	for _, v in pairs(G.jokers.cards) do
		if v.ability.name == "Eva Maroon" then recalculate_maroon(v) end
	end
end

local function recalculate_maroon_joker(joker)
	local xmult = 1
	for k, v in pairs(G.playing_cards) do 
		if v.ability.effect ~= 'Stone Card' then
			if v:is_suit('Hearts') or v:is_suit('Diamonds') then xmult = xmult + joker.ability.extra.xmult_add end
			if v:is_suit('Clubs' ) or v:is_suit('Spades')   then xmult = xmult - joker.ability.extra.xmult_sub end
			--    if v.base.suit == 'Hearts' or v.base.suit == 'Diamonds' then xmult = xmult + joker.ability.extra.xmult_add   
			--elseif v.base.suit == 'Clubs'  or v.base.suit == 'Spades'   then xmult = xmult - joker.ability.extra.xmult_sub end
		end
	end
	joker.ability.extra.current_xmult = xmult
end

local function recalculate_simple_joker(joker)
	local chips = 0
	for _, v in pairs(G.playing_cards) do 
		if v.ability.effect == 'Base' and not v.seal and not v.edition then
			chips = chips + joker.ability.extra.chips_add
		end
	end
	joker.ability.extra.chips = chips
end





--[===

--[ Square Deck
SMODS.Back{
	name = "SquareDeck",
	key = "square",
	pos = {x = 1, y = 3},
	config = { 
		discards = 1, 
		hand_size = -3, 
		consumable_slots = 4, 
		consumables = { 'c_familiar', 'c_grim' },
	},
	loc_txt = {
		name ="Square Deck",
		text={
			"Start with a Deck",
			"full of {C:attention}Face cards{}",
			"{C:attention}Familiar{} and {C:attention}Grim{} cards"
		},
    },
	loc_vars = function(self)
		return { vars = { self.config.discards, self.config.hands }}
	end,
	apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
					if G.playing_cards[i]:get_id() <= 10 then 
						G.playing_cards[i]:start_dissolve(nil, true) 
					end
                end
                G.GAME.starting_deck_size = 16
                return true
            end
        }))
    end
}
--]]

--[ Tag Deck (finished?)
SMODS.Back{
	name = "Tag Deck",
	key = "tag",
	pos = {x = 0, y = 0},
	config = { 
		eva_tag_deck = true
	},
	loc_txt = {
		name ="Tag Deck",
		text={
			"Create 2 random {C:attention}Tags{}",
			"every blind"
		},
    }
}
--]]

--[ Unstable Deck
SMODS.Back{
	name = "Unstable Deck",
	key = "unstable",
	pos = {x = 0, y = 0},
	config = { 
		eva_unstable_deck = true
	},
	loc_txt = {
		name ="Unstable Deck",
		text={
			"Rerolls every scored card"
		},
    },
	trigger_effect = function(self, args)
		if args.context == "final_scoring_step" then
			local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
			for i = 1,#scoring_hand do
				--local card = G.hand.cards[i]
				local card = scoring_hand[i]
				local new_id = math.random(2, 14)
				local new_suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('d6'))
				card:flip()
				card:set_base(G.P_CARDS[new_suit ..'_'.. rank_to_string(new_id)])
				
				-- Give random enhancement
				if pseudorandom('d6_chance_enhancement') < 0.3 then 
					card:set_ability(get_random_enhancement('deckunstable_enhancement', true), nil, true)
				end
				
				-- Random edition
				if not card.edition and pseudorandom('deckunstable_chance_edition') < 0.05 then
					card:set_edition(poll_edition('aura', nil, true, true), true)
				end
				
				-- Random seal
				if not card.seal and pseudorandom('deckunstable_chance_seal') < 0.12 then
					card:set_seal(get_random_seal('deckunstable_seal'))
				end
				
				if i <= 3 then play_sound('card1') end
				card:flip()
				delay(0.05)
			end
			return args.chips, args.mult
		end
	end
}
--]]

--]===]


local challenges = {
	{
        name = "Night on Mars",
        id = 'c_mod_evanightonmars',
        text = {
			"Start with {C:attention}Life on Mars{}",
			"and {C:attention}Weakness{}"
		},
        rules = {
            custom = {},
            modifiers = {
                { id = 'joker_slots', value = 1 },
            }
        },
        jokers = {
            {id = 'j_lifeonmars', eternal = true}, 
            {id = 'j_weakness', edition = 'negative'}
        },
        consumeables = {},
        vouchers = {},
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                {id = 'j_invisible'},
                {id = 'c_judgement'},
				{id = 'c_hex'},
				{id = 'c_ankh'},
				{id = 'c_ectoplasm'},
				{id = 'c_wraith'},
		        {id = 'c_soul'},
				{id = 'v_blank'},
				{id = 'v_antimatter'}
		    },
            banned_tags = {
				{id = 'tag_uncommon'},
				{id = 'tag_foil'},
				{id = 'tag_holo'},
				{id = 'tag_polychrome'},
				{id = 'tag_top_up'}
				--,{id = 'tag_buffoon'}
            },
            banned_other = {
            }
        }
    },
	
	{
        name = "Major Arcana",
        id = 'c_mod_evamajorarcana',
        text = {
			"Start with {C:attention}Life on Mars{}",
			"and {C:attention}Weakness{}"
		},
        rules = {
            custom = {
				{ id = 'no_shop_jokers' }
			},
            modifiers = {
            }
        },
        jokers = {
            {id = 'j_endlessloop', edition = 'negative'}, 
            {id = 'j_tarot_expansion'}
        },
        consumeables = {
            {id = 'c_judgement'}
		},
        vouchers = {
            {id = 'v_tarot_merchant'},
            {id = 'v_crystal_ball'},
		},
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                {id = 'j_riff_raff'},						-- not allowed! haha
                {id = 'p_buffoon_normal_1', ids = {			-- block all Joker and Standart packs
                    'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1'
                }},
                {id = 'p_standard_normal_1', ids = {			-- block all Joker and Standart packs
                    'p_celestial_normal_3','p_celestial_normal_4','p_celestial_jumbo_2','p_celestial_mega_2',
					'p_standard_normal_1','p_standard_normal_2','p_standard_normal_3','p_standard_normal_4','p_standard_jumbo_1','p_standard_jumbo_2','p_standard_mega_1','p_standard_mega_2'
                }},
		    },
            banned_tags = {
				{id = 'tag_uncommon'},
				{id = 'tag_foil'},
				{id = 'tag_holo'},
				{id = 'tag_polychrome'},
				{id = 'tag_top_up'},
				{id = 'tag_buffoon'}
            },
            banned_other = {	
            }
        }
    }
}

local jokers = {
	-- Support
	endlessloop = {
		name = "Endless Loop",
		text = {
			"Using any {C:attention}consumable{}",
			"give {C:green}#1# in #2#{} chance",
			"to create her copy",
			"{C:inactive}(#4# uses this round)",
		},
		config = { extra = { odds = 3, limit = 10, repeats = 0 } },
		rarity = 2,
		cost = 5,
        blueprint_compat = false,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Tarot',
        calculate = function(self, context)
			if 			context.using_consumeable 
					and context.consumeable 
					and context.consumeable.ability.name ~= 'The Fool' 
					and context.consumeable.ability.name ~= 'The Emperor' 
					and pseudorandom('endlessloop') < G.GAME.probabilities.normal/self.ability.extra.odds 
					and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit 
					and self.ability.extra.repeats < self.ability.extra.limit then 
				self.ability.extra.repeats = self.ability.extra.repeats + 1
				G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
				G.E_MANAGER:add_event(Event({
					trigger = 'before',
					delay = 0.0,
					func = (function()
							local card = copy_card(context.consumeable, nil)
							card:add_to_deck()
							G.consumeables:emplace(card)
							G.GAME.consumeable_buffer = 0	
										
							-- Message
							card_eval_status_text(self, "extra", nil, nil, nil, {
								message = localize("eva_repeat"),
								colour = G.C.PURPLE
							})
						return true
					end)}))
		
			end
			
			-- Restore limits at the end of round
			if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
				self.ability.extra.repeats = 0
            end
        end,
		loc_def = function(self)
			return { "" .. (G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds, self.ability.extra.limit, self.ability.extra.limit - self.ability.extra.repeats }
		end,
	},
	
	-- Chips/mult
	plasmatic = {
		name = "Plasmatic Joker",
		text = {
			"If player have any {C:attention}consumable",
			"at the end of the shop, destroy one",
			"and balance {C:chips}chips{} and {C:mult}mult{}",
			"{C:inactive}#1#{}",
		},
		config = { extra = { active = false } },
		rarity = 2,
		cost = 7,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Mult',
        calculate = function(self, context)
			-- Activate?
			if context.setting_blind and not context.blueprint and not self.getting_sliced and not (context.blueprint_card or self).getting_sliced and not self.ability.extra.active then
				for i = 1, #G.consumeables.cards do
					if G.consumeables.cards[i].ability.set == "Tarot" and not G.consumeables.cards[i].getting_sliced then
						self.ability.extra.active = true
						G.consumeables.cards[i].getting_sliced = true
						G.E_MANAGER:add_event(Event({
							func = function()
								(context.blueprint_card or self):juice_up(0.8, 0.8)
								G.consumeables.cards[i]:start_dissolve({ G.C.RED }, nil, 1.6)
								return true
							end,
						}))
						if not (context.blueprint_card or self).getting_sliced then
							card_eval_status_text((context.blueprint_card or self), "extra", nil, nil, nil, { message = localize("k_active_ex") })
						end
						return nil, true
					end
				end
				
				if tarot_to_destroy then
				end
			end
			
			-- Balance
            if SMODS.end_calculate_context(context) then
				if not self.ability.extra.active then
					-- Same, but without any messages
					for i = 1, #G.consumeables.cards do
						if G.consumeables.cards[i].ability.set == "Tarot" and not G.consumeables.cards[i].getting_sliced then
							G.consumeables.cards[i].getting_sliced = true
							self.ability.extra.active = true
							G.E_MANAGER:add_event(Event({
								func = function()
									(context.blueprint_card or self):juice_up(0.8, 0.8)
									G.consumeables.cards[i]:start_dissolve({ G.C.RED }, nil, 1.6)
									return true
								end,
							}))
							break
						end
					end
				end
				
				if self.ability.extra.active then 	
					local balance = (hand_chips + mult) / 2;
					return {
						chip_mod = balance - hand_chips,
						mult_mod = balance - mult,
						card = self,
						message = localize("eva_balance")
					}
				else
					return {
						card = self,
						message = localize("k_none")
					}
				end
            end
			
			-- Deactivate
			if context.end_of_round and not context.individual and not context.repetition and not context.blueprint and self.ability.extra.active then
				self.ability.extra.active = false
				return {
					card = self,
					message = localize("k_reset")
				}
            end
        end,
		loc_def = function(self)
			return { self.ability.extra.active and "Active" or "Inactive" }
		end,
	},
	
	-- TODO: check randomizer of start cards, color
	-- Money
	goldenidol = {         
		name = "Golden Idol",
		text = {
            "If {C:attention}discard{} have only one",
			"{C:attention}#2#{} of {C:spades}#3#{},",
			"earn {C:money}$#1#{}",
			"{s:0.8}Card changes every round"
		},
		ability_name = "Eva Golden Idol",
		config = { extra = { cash = 15, idol_suit = 'Spades', idol_rank = 'Ace', idol_id = 14 } },
		rarity = 2,
		cost = 5,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Money',
		calculate = function(self, context)
			-- I'm Mister Crabs, I love money!
			-- and G.GAME.current_round.hands_played == 0
            if context.discard and #context.full_hand == 1 and context.other_card:get_id() == self.ability.extra.idol_id and context.other_card:is_suit(self.ability.extra.idol_suit) then
                ease_dollars(self.ability.extra.cash)
                return {
                    message = localize('$') .. self.ability.extra.cash,
                    colour = G.C.MONEY,
                    delay = 0.45, 
                    card = self
                }
            end
			
			-- Changes at end of round
			if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
				self.ability.extra.idol_rank = 'Ace'
				self.ability.extra.idol_suit = 'Spades'
				local idol_card = get_random_card('golden_idol' .. G.GAME.round_resets.ante)
				if idol_card then 
					self.ability.extra.idol_suit = idol_card.base.suit
					self.ability.extra.idol_id   = idol_card.base.id
					self.ability.extra.idol_rank = rank_name(idol_card.base.id)
				end
            end
		end,
		loc_def = function(self)
			return { self.ability.extra.cash, self.ability.extra.idol_rank, self.ability.extra.idol_suit }
		end,
	},
	
	-- Support
	weakness = {
		name = "Weakness",
		text = {
            "If all played cards of the {C:attention}first hand{}",
			"are the {C:attention}same rank{},",
			"{C:attention}decrease{} rank and remove",
			"{C:attention}Enhancement{}, {C:attention}Seal{} and {C:attention}Edition{}"
		},
		config = { extra = { mult = 0, mod_conv = 'up_rank' } },
		rarity = 1,
		cost = 5,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Support',
		calculate = function(self, context)
			if context.cardarea == G.jokers and context.before and not context.repetition then
				local is_active = true
				local saved_rank = -1
				for i = 1, #context.full_hand do 
					local card = context.full_hand[i]
					if card.ability.effect == 'Stone Card' then is_active = false end
					if i == 1 then saved_rank = card.base.id end
					if i ~= 1 and saved_rank ~= card.base.id then is_active = false end
				end
				
				
				if is_active then 
					for k, v in ipairs(context.full_hand) do
						if not v.vampired and v.config.center ~= G.P_CENTERS.c_base then 
							v.vampired = true
						end
						
						-- Decrease rank
						local suit_prefix = string.sub(v.base.suit, 1, 1)..'_'
						local rank_suffix = v.base.id == 2 and 14 or math.max(v.base.id-1, 2)
						v:set_base(G.P_CARDS[suit_prefix .. rank_to_string(rank_suffix)])	
						
						-- Debuff it!
						--if not v.debuff then
							--v.ability.perma_debuff = true
							--v:set_debuff(true)
						--end
						
						-- previous version: remove all Enhancement and other stuff instead of debuffing
						if not v.debuff then
							if v.config.center ~= G.P_CENTERS.c_base then v:set_ability(G.P_CENTERS.c_base, nil, true) end
							if v.edition then card:set_edition(nil, true) end
							if v.seal then card:set_seal(nil) end
						end
						
						G.E_MANAGER:add_event(Event({
							func = function()
								v:juice_up()
								v.vampired = nil
								return true
							end
						})) 
					end
					
					return {
						message = localize("eva_weak"),
						card = self
					}
				end
			end
		end,
		loc_def = function(self)
			return { self.ability.extra.mult }
		end,
	},
	
	-- TODO: text appears too late
	-- Support (tag)
	lifeonmars = {
		name = "Life on Mars",
		text = {
			"If {C:attention}poker hand{} is a",
			"{C:attention}#1#{}, give a",
			"{C:dark_edition}Negative Tag{}"
		},
		config = { extra = { poker_hand = 'Four of a Kind' } },
		rarity = 2,
		cost = 6,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Tag',
		calculate = function(self, context)
            if SMODS.end_calculate_context(context) and next(context.poker_hands[self.ability.extra.poker_hand]) then
                add_tag(Tag('tag_negative'))
				card_eval_status_text(self, "extra", nil, nil, nil, {
					message = localize("eva_addtag"),
					colour = G.C.PURPLE
				})
            end
		end,
		loc_def = function(self)
			return { self.ability.extra.poker_hand }
		end,
	},
	
	-- Support (tag)
	tagged = {
		name = "Tagged",
		text = {
			"Create a random {C:attention,T:tag_double}Tag{}",
			"when {C:attention}Blind{} is selected",
			"{C:inactive}(Must have room)",
		},
		config = { extra = { } },
		rarity = 1,
		cost = 5,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = false,
		effect = 'Tag',
		calculate = function(self, context)
            if context.setting_blind and not self.getting_sliced and not (context.blueprint_card or self).getting_sliced then
				local tag_name = get_random_tag('j_eva_tagged')
				local tag = Tag(tag_name)
				if tag_name == 'tag_orbital' then
					local _poker_hands = {}
					for k, v in pairs(G.GAME.hands) do
						if v.visible then _poker_hands[#_poker_hands+1] = k end
					end
					tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed('j_eva_tagged_orbital_tag'))
					--tag:set_ability()	-- doesn't work for unknown reason
				end
				add_tag(tag)
				
				-- Show message
				card_eval_status_text(self, "extra", nil, nil, nil, {
					message = localize("eva_addtag"),
					colour = G.C.PURPLE
				})
            end
		end,
		loc_def = function(self)
			return { }
		end,
	},
	
	-- Support
	precognition = {
		name = "Precognition",
		text = {
            "Shows two next cards in the deck",
			"Charge by selling Jokers for {C:blue}1{}, {C:green}2{}, {C:red}4{} or {C:legendary,E:1}12{} rounds",
			"Current charges: {C:attention}#1#{}",
			"Next cards: {C:attention}#2#{} of {C:diamonds}#3#{}, {C:attention}#4#{} of {C:diamonds}#5#{}"
		},
		ability_name = "Eva Precognition",
		config = { extra = { charges = 3, card1_rank = '##', card1_suit = '######', card2_rank = '##', card2_suit = '######' } },
		rarity = 2,
		cost = 4,
		blueprint_compat = false,
		eternal_compat = true,
		unlocked = true,
		discovered = false,
		effect = 'Support',
		calculate = function(self, context)
			-- Read remained cards
            if (    context.cardarea == G.jokers and not context.before and not context.after
			     or context.discard
				 or context.first_hand_drawn) 
				 and self.ability.extra.charges > 0 and G.deck and not context.blueprint then
				
				self.ability.extra.card1_rank = '##'
				self.ability.extra.card1_suit = '######'
				self.ability.extra.card2_rank = '##'
				self.ability.extra.card2_suit = '######'
				
				local hand_size = G.hand and G.hand.config.card_limit or 8
				local cnt_highlighted = G.hand and G.hand.highlighted and #G.hand.highlighted or 0
				local del = hand_size - #G.hand.cards + cnt_highlighted
				if G.deck.cards[del + 1] then 
					self.ability.extra.card1_rank = rank_name(G.deck.cards[#G.deck.cards - del - 0].base.id)
					self.ability.extra.card1_suit =           G.deck.cards[#G.deck.cards - del - 0].base.suit
				end
				if G.deck.cards[del + 2] then 
					self.ability.extra.card1_rank = rank_name(G.deck.cards[#G.deck.cards - del - 1].base.id)
					self.ability.extra.card1_suit =           G.deck.cards[#G.deck.cards - del - 1].base.suit
				end
			end
			
			-- -1 charge at end of round
			if context.end_of_round and not context.individual and not context.repetition and not context.blueprint and self.ability.extra.charges > 0 then
				self.ability.extra.charges = self.ability.extra.charges - 1
				self.ability.extra.card1_rank = '##'
				self.ability.extra.card1_suit = '######'
				self.ability.extra.card2_rank = '##'
				self.ability.extra.card2_suit = '######'
				return {
					card = self,
					message = localize { "-1 charge" }
				}
            end
		end,
		loc_def = function(self)
			return { self.ability.extra.charges, self.ability.extra.card1, self.ability.extra.sep1, self.ability.extra.card2, self.ability.extra.sep2, self.ability.extra.card3 }
		end,
	},
	
	-- TODO: rework?!
	-- Mult (scale)
	crystaljoker = {
		name = "Crystal Joker",
		text = {
			"{C:mult}+#1#{} Mult per {C:attention}#3#{} card scored,",
			"{C:mult}-#2#{} Mult per {C:attention}#3#{} card discard,",
					"suit changes every round",
                    "{C:inactive}(Currently {C:mult}+#4#{C:inactive} Mult)"
		},
		config = { extra = { mult_add = 1, mult_sub = 3, suit = 'Spades', current_mult = 0 } },
		rarity = 1,
		cost = 4,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = false,
		effect = 'Mult',
		calculate = function(self, context)
            if SMODS.end_calculate_context(context) then
				return {
					mult_mod = self.ability.extra.current_mult,
					card = self,
					message = localize { type = 'variable', key = 'a_mult', vars = { self.ability.extra.current_mult or 0 } }
				}
            end
			
			-- Play
            if context.individual and context.cardarea == G.play and not context.blueprint and context.other_card:is_suit(self.ability.extra.suit) then
                self.ability.extra.current_mult = self.ability.extra.current_mult + self.ability.extra.mult_add
				card_eval_status_text(self, "extra", nil, nil, nil, {
					message = "+" .. self.ability.extra.mult_add .. " Mult",
					colour = G.C.PURPLE
				})
            end
			
			-- Discard
            if context.discard and not context.blueprint and context.other_card:is_suit(self.ability.extra.suit) and self.ability.extra.current_mult > 0 then
				local _sub = math.min(self.ability.extra.current_mult, self.ability.extra.mult_sub) 
                self.ability.extra.current_mult = self.ability.extra.current_mult - _sub
				card_eval_status_text(self, "extra", nil, nil, nil, {
					message = "-" .. _sub .. " Mult",
					colour = G.C.PURPLE
				})
            end
			
			-- Changes at end of round
			if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
				self.ability.extra.suit = 'Spades'
				local idol_card = get_random_card('crystal_joker' .. G.GAME.round_resets.ante)
				if idol_card then 
					self.ability.extra.suit = idol_card.base.suit
				end
            end
		end,
		loc_def = function(self)
			return { self.ability.extra.mult_add, self.ability.extra.mult_sub, self.ability.extra.suit, self.ability.extra.current_mult }
		end,
	},
	
	-- XMult (scale)
	maroon = {
		name = "Maroon",
		text = {
			"Gains {X:mult,C:white}X#2#{} Mult for each {C:heart}red{} card",
			"and {X:mult,C:white}-X#3#{} Mult for each {C:spades}black{} card",
			"in a full deck",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
		},
		ability_name = 'Eva Maroon',
		config = { extra = { current_xmult = 0, xmult_add = 0.1, xmult_sub = 0.1 } },
		rarity = 2,
		cost = 7,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'XMult',
		calculate = function(self, context)
			if SMODS.end_calculate_context(context) and self.ability.extra.current_xmult >= 1 then
				recalculate_maroon_joker(self)
				return {
					Xmult_mod = self.ability.extra.current_xmult,
					card = self,
					message = localize {
						type = "variable",
						key = "a_xmult",
						vars = { self.ability.extra.current_xmult }
					}
				}
			end
		end,
		loc_def = function(self)
			return { self.ability.extra.current_xmult, self.ability.extra.xmult_add, self.ability.extra.xmult_sub }
		end,
	},
	
	-- XMult (scale)
	ladder = {
		name = "Ladder",
		text = {
			"Gain {X:mult,C:white}X#2#{} Mult when {C:attention}#3#{} is scored,",
			"upscale a rank by {C:attention}1{}",
			"{C:inactive}(can upscale multiple times per hand){}",
			"{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult)",
		},
		config = { extra = { rank = 2, rank_name = '2', current_xmult = 1, xmult_add = 0.1 } },
		rarity = 2,
		cost = 8,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'XMult',
		calculate = function(self, context)
			if context.individual and context.cardarea == G.play and not context.other_card.debuff then
				local rank = self.ability.extra.rank
				local move_forward = true
				local card_count = 0
				while move_forward and card_count < 13 do
					for i = 1,#context.scoring_hand do
						if 		context.scoring_hand[i].base.id == rank 
							and context.scoring_hand[i].ability.effect ~= 'Stone Card'
							and not context.scoring_hand[i].debuff
						then
							move_forward = true
							card_count = card_count + 1
							rank = rank + 1
							if rank > 14 then rank = 2 end
							
							-- Visualize!
							if context.other_card == #context.scoring_hand[i] then
								return {
									extra = {focus = self, message = localize('k_upgrade_ex')},
									card = self,
									colour = G.C.MULT
								}
							end
							break
						end
					end
				end
			end
			
			if SMODS.end_calculate_context(context) then
				local cards = {}
				local move_forward = true
				while move_forward and #cards < 13 do
					move_forward = false
					for i = 1,#context.scoring_hand do
						if 		context.scoring_hand[i].base.id == self.ability.extra.rank 
							and context.scoring_hand[i].ability.effect ~= 'Stone Card'
							and not context.scoring_hand[i].debuff
						then
							move_forward = true
							cards[#cards] = context.scoring_hand[i]
							self.ability.extra.rank = self.ability.extra.rank + 1
							if self.ability.extra.rank > 14 then self.ability.extra.rank = 2 end
							break
						end
					end
				end
				
				if #cards > 0 then
					self.ability.extra.current_xmult = self.ability.extra.current_xmult + self.ability.extra.xmult_add * #cards
					self.ability.extra.rank_name = rank_name(self.ability.extra.rank)
				end
				
				return {
                    message = localize {
                        type = "variable",
                        key = "a_xmult",
                        vars = { self.ability.extra.current_xmult }
                    },
                    Xmult_mod = self.ability.extra.current_xmult
                }
			end
		end,
		loc_def = function(self)
			return { self.ability.extra.current_xmult, self.ability.extra.xmult_add, self.ability.extra.rank_name }
		end,
	},
	
	-- Support
	useless_joker = {
		name = "Useless Joker",
		text = {
            "+{C:dark_edition}#1#{} Joker slot"
		},
		config = { extra = { j_slots = 1 } },
		rarity = 2,
		cost = 1,
		blueprint_compat = false,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Support',
		calculate = function(self, context)
		end,
		loc_def = function(self)
			return { self.ability.extra.j_slots }
		end,
	},
	
	-- TODO: broke when there is no place
	-- Support (seal)
	broken_seal_depatcher = {
		name = "Broken Seal Depatcher",
		text = {
            "When card with a {C:attention}seal{} scored,",
			"destroy {C:attention}seal{} and create",
			"a random {C:spectral}Spectral Seal card{}",
			"{C:red}Broke if no place in consumable slots{}"
		},
		config = { extra = { cards = 1 } },
		rarity = 2,
		cost = 7,
		blueprint_compat = false,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Support',
		calculate = function(self, context)
			if context.individual and context.cardarea == G.play and context.other_card.seal and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then 
					-- Destroy seal on the card
					context.other_card:juice_up(0.3, 0.5)
					context.other_card:set_seal(nil, nil, true)
					
					-- Give a random Seal Spectral card
					local list_spectrals = { 'c_deja_vu', 'c_medium', 'c_talisman', 'c_trance' }
					local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, list_spectrals[math.random(#list_spectrals)])
					card:add_to_deck()
					G.consumeables:emplace(card)
					G.GAME.consumeable_buffer = 0
					
					-- Message
					return {
						extra = {focus = self, message = localize('eva_detach')},
						card = self,
						colour = G.C.PURPLE
					}
				else 
					--[=[
					G.E_MANAGER:add_event(Event({
						func = function()
							
							--[[
							self.T.r = -0.2
							self:juice_up(0.3, 0.4)
							self.states.drag.is = true
							self.children.center.pinch.x = true
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
								func = function()
										G.jokers:remove_card(self)
										self:remove()
										self = nil
									return true; end})) 
							--]]
							
							return true
						end
					})) 
					--]=]
					
					-- Broke
					play_sound('glass'..math.random(1, 6), math.random()*0.2 + 0.9,0.5)
					self:shatter()
					return {
						message = localize('eva_broken'),
						colour = G.C.PURPLE
					}
				end
			end
		end,
		loc_def = function(self)
			return { }
		end,
	},
	
	-- Support
	dice = {
		name = "The Dice",
		text = {
            "Rerolls {C:attention}first card{} in the hand",
			"if played hand contains {C:attention}5{} [##] scoring cards",
			"{C:green}#1# in #2#{} chance to add random Seal",
			"{C:green}#1# in #3#{} chance to add random Edition"
		},
		config = { extra = { odds_seal = 3, odds_edition = 6, cards = 5 } },
		rarity = 2,
		cost = 8,
		blueprint_compat = true,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Support',
		calculate = function(self, context)
			if SMODS.end_calculate_context(context) and #context.scoring_hand >= 5 and #G.hand.cards > 0 then -- save from Cryptid param reroll thingy -- >= self.ability.extra.cards then
			
				-- Reroll
				self.ability.extra.current_cards = 0
				G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.1, func = function()
					local card = G.hand.cards[1]
					local new_id = math.random(2, 14)
					local new_suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('d6'))
					card:flip()
					card:set_base(G.P_CARDS[new_suit ..'_'.. rank_to_string(new_id)])
					
					-- Random enhancement
					local enhancement = pseudorandom('d6_chance_enhancement') < 0.75 	and get_random_enhancement('d6_enhancement', true) or
										card.ability.effect == 'Stone Card'				and G.P_CENTERS.c_base or nil
					if enhancement then v:set_ability(enhancement, nil, true) end
					
					-- Random seal
					if not card.seal and pseudorandom('d6_chance_seal') < G.GAME.probabilities.normal/self.ability.extra.odds_seal then
						card:set_seal(get_random_seal('d6_seal'))
					end
					
					-- Random edition
					if pseudorandom('d6_chance_edition') < G.GAME.probabilities.normal/self.ability.extra.odds_edition then
						card:set_edition(poll_edition('aura', nil, true, true), true)
					end
					
					-- Message (working? idk. need to check)
					card_eval_status_text(self, "extra", nil, nil, nil, {
						message = localize("eva_reroll"),
						colour = G.C.PURPLE
					})
					
					play_sound('card1')
					card:juice_up(0.3, 0.3)
					card:flip()
					
					return true end 
				}))
			end
		end,
		loc_def = function(self)
			return { "" .. (G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds_seal, self.ability.extra.odds_edition }
		end,
	},
	
	--[[ Rerolls every 6 non-scoring cards
	-- Support
	dice = {
		name = "The Dice",
		text = {
            "Rerolls {C:attention}leftmost card{} in the hand",
			"every {C:attention}#4#{} {C:inactive}[#5#]{} played non-scoring cards",
			"{C:green}#1# in #2#{} chance to add random Seal",
			"{C:green}#1# in #3#{} chance to add random Edition"
		},
		config = { extra = { odds_seal = 3, odds_edition = 6, max_cards = 6, current_cards = 0 } },
		rarity = 2,
		cost = 6,
		blueprint_compat = false,
		eternal_compat = true,
		unlocked = true,
		discovered = true,
		effect = 'Support',
		calculate = function(self, context)
			if SMODS.end_calculate_context(context) then
				for _, v in ipairs(context.full_hand) do
					
					local is_scoring = false
					for _, v2 in ipairs(context.scoring_hand) do if v == v2 then is_scoring = true end end
					--if context.scoring_hand and not table.contains(context.scoring_hand, v) and self.ability.extra.current_cards < self.ability.extra.max_cards then
					if context.scoring_hand and not is_scoring and self.ability.extra.current_cards < self.ability.extra.max_cards then
						self.ability.extra.current_cards = self.ability.extra.current_cards + 1
					end
					
					if self.ability.extra.current_cards >= self.ability.extra.max_cards and #G.hand.cards > 0 then 
						-- Reroll
						self.ability.extra.current_cards = 0
						G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.1, func = function()
							if #G.hand.cards > 0 then
								local card = G.hand.cards[1]
								local new_id = math.random(2, 14)
								local new_suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('d6'))
								card:flip()
								card:set_base(G.P_CARDS[new_suit ..'_'.. rank_to_string(new_id)])
								
								-- Give random enhancement
								
								
								if pseudorandom('d6_chance_enhancement') < 0.75 then 
									card:set_ability(get_random_enhancement('d6_enhancement', true), nil, true)
								end
								
								-- Random seal
								if not card.seal and pseudorandom('d6_chance_seal') < G.GAME.probabilities.normal/self.ability.extra.odds_seal then
									card:set_seal(get_random_seal('d6_seal'))
								end
								
								-- Random edition
								if pseudorandom('d6_chance_edition') < G.GAME.probabilities.normal/self.ability.extra.odds_edition then
									card:set_edition(poll_edition('aura', nil, true, true), true)
								end
								
								-- Message
								card_eval_status_text(self, "extra", nil, nil, nil, {
									message = localize("eva_reroll"),
									colour = G.C.PURPLE
								})
								
								play_sound('card1')
								card:juice_up(0.3, 0.3)
								card:flip()
							end
								
							return true end 
						}))
					end
				end
			end
		end,
		loc_def = function(self)
			return { "" .. (G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds_seal, self.ability.extra.odds_edition, self.ability.extra.max_cards, self.ability.extra.current_cards }
		end,
	},
	--]]
	
	-- TODO: image
	-- XMult
	money_control = {
		name = "Money Control",
		text = {
			"{X:red,C:white} X#1# {} Mult if {C:money}money count{} is even"
		},
		config = { extra = { Xmult = 2 } },
		rarity = 1,
		cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'XMult',
        calculate = function(self, context)
            if SMODS.end_calculate_context(context) then
				if math.fmod(G.GAME.dollars, 2) < 1 then		-- normally it would be math.fmod=0, but... Cryptid.
					return {
                        message = localize {
                            type = "variable",
                            key = "a_xmult",
                            vars = { self.ability.extra.Xmult }
                        },
						Xmult_mod = self.ability.extra.Xmult,
						card = self
					}
				end
            end
        end,
		loc_def = function(self)
			return { self.ability.extra.Xmult }
		end,
	},
	
	-- Support
	dataminer = {
		name = "Dataminer",
		text = {
			"After discarding {C:attention}#2#{} cards",
			"permanently gain {C:blue}+#3#{} hand",
			"{C:inactive}(Currently {C:red}#1#{C:inactive} cards)"
		},
		config = { extra = { current_discards = 0, limit = 109, hands = 1 } },
		rarity = 3,
		cost = 9,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Support',
		yes_pool_flag = 'dataminer_appears',
        calculate = function(self, context)
            if context.discard and not context.blueprint then
				self.ability.extra.current_discards = self.ability.extra.current_discards + 1
				if self.ability.extra.current_discards == self.ability.extra.limit then
					-- Add +1 hand
					G.GAME.round_resets.hands = G.GAME.round_resets.hands + self.ability.extra.hands
					ease_hands_played(self.ability.extra.hands)
					
					-- Message
					G.E_MANAGER:add_event(Event({
						func = function()
							play_sound('tarot1')
							self.T.r = -0.2
							self:juice_up(0.3, 0.4)
							self.states.drag.is = true
							self.children.center.pinch.x = true
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
								func = function()
										G.jokers:remove_card(self)
										self:remove()
										self = nil
									return true; end})) 
							return true
						end
					})) 
					return {
						message = localize('eva_dataminer'),
						colour = G.C.FILTER
					}
				end
            end
        end,
		loc_def = function(self)
			return { self.ability.extra.current_discards, self.ability.extra.limit, self.ability.extra.hands }
		end,
	},
	
	-- TODO: image
	-- Support
	science = {
		name = "Science",
		text = {
			"Create {C:attention}Brainstorm{}",
			"when discard a {E:1,C:attention}#1#{}",
			"{S:1.1,C:red,E:2}self destructs{}",
		},
		config = { extra = { hand_type = 'Royal Flush' } },
		rarity = 3,
		cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Support',
        calculate = function(self, context)
			if 			context.discard 
					and not context.blueprint 
					and context.other_card == context.full_hand[#context.full_hand] 
					and #context.full_hand >= 5
			then
				local text, loc_disp_text, poker_hands, scoring_hand, disp_text = G.FUNCS.get_poker_hand_info(context.full_hand)
                if disp_text == 'Royal Flush' then 
                --if next(eval[self.ability.extra.hand_type]) then 
					-- Create Joker
					local card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_brainstorm')
					card:add_to_deck()
					G.jokers:emplace(card)
				
					-- Message
					G.E_MANAGER:add_event(Event({
						func = function()
							play_sound('tarot1')
							self.T.r = -0.2
							self:juice_up(0.3, 0.4)
							self.states.drag.is = true
							self.children.center.pinch.x = true
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
								func = function()
										G.jokers:remove_card(self)
										self:remove()
										self = nil
									return true; end})) 
							return true
						end
					})) 
					return {
						message = localize('eva_science'),
						colour = G.C.FILTER
					}
				end
			end
        end,
		loc_def = function(self)
			return { self.ability.extra.hand_type }
		end,
	},
	
	-- Support
	tarot_expansion = {
		name = "Tarot Expansion",
		text = {
			"Расширяет [] при выборе карт Таро на 1",
			
			
			"Allow to choose one more card to",
			"{C:attention}Enhancement{} with Tarot card"
		},
		ability_name = "Eva Tarot Expansion",
		config = { extra = { add = 1 } },
		rarity = 1,
		cost = 3,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Support',
		calculate = function(self, context)
		end,
		loc_def = function(self)
			return { self.ability.extra.add }
		end,
	},
	
	-- TODO: check
	-- Chips
	fantasy_seal = {
		name = "Fantasy Seal",
		text = {
			"Cards with a {C:attention}seal{}",
			"give {C:chips}+#1#{} Chips",
			"when scored"
		},
		config = { extra = { chips = 80 } },
		rarity = 1,
		cost = 6,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Chips',
        calculate = function(self, context)
			if context.individual and context.cardarea == G.play then -- and context.other_card.seal
				return {
					message = localize {
						type = "variable",
						key = "a_chips",
						vars = { self.ability.extra.chips }
					},
					chip_mod = self.ability.extra.chips,
					card = self
				}
			end
        end,
		loc_def = function(self)
			return { self.ability.extra.chips }
		end,
	},
	
	-- TODO: visuals, description
	-- Money
	poker_chip = {
		name = "Poker Chip",
		text = {
			"Each played {C:attention}#3#{} have",
			"{C:green}#1# in #2#{} chance to give you {C:money}$#4#{},",
			"{C:red}-$#5#{} otherwise",
		},
		config = { extra = { rank = 7, money_add = 5, money_sub = 2, odds = 2 } },
		rarity = 1,
		cost = 7,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Money',
        calculate = function(self, context)
			-- Play
            if context.individual and context.cardarea == G.play and context.other_card.base.id == 7 then
				local cash = pseudorandom('eva_pokerchip') < G.GAME.probabilities.normal/self.ability.extra.odds and self.ability.extra.money_add or (-self.ability.extra.money_sub)
                return {
					dollars = cash,
					card = self,
					colour = cash > 0 and G.C.MONEY or G.C.RED
				}
            end
        end,
		loc_def = function(self)
			return { "" .. (G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds, 
				self.ability.extra.rank, self.ability.extra.money_add, self.ability.extra.money_sub }
		end,
	},

	-- Chips
	simple_joker = {
		name = "Simple Joker",
		text = {
			"Gains {C:chips}+#1#{} chips for every card",
			"in the full deck without",
			"{C:attention}Enhancement{}, {C:attention}Seal{} or {C:attention}Edition{}",
			"(current chips: {C:chips}#2#{})",
		},
		config = { extra = { chips_add = 2, chips = 0 } },
		rarity = 1,
		cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        effect = 'Chips',
        calculate = function(self, context)
			-- Play
            if SMODS.end_calculate_context(context) then
				recalculate_simple_joker(self)
				return {
					message = localize {
						type = "variable",
						key = "a_chips",
						vars = { self.ability.extra.chips }
					},
					chip_mod = self.ability.extra.chips,
					card = self
				}
            end
        end,
		loc_def = function(self)
			return { self.ability.extra.chips_add, self.ability.extra.chips }
		end,
	},

}

local spectrals = {
	shredder = {
		name = "Shredder",
		text = {
			"Split choosen {C:attention}card{} into 2s ",
			"with the same {C:attention}Enhancement,",
			"Seal and Edition{}"
		},
		config = { extra = { cards = 1, remove_card = true, min_highlighted = 1, max_highlighted = 1 } },
		cost = 4,
		cost_mult = 1,
		discovered = true,
		can_use = function(card) 
			return #G.hand.highlighted == 1 and G.hand.highlighted[1].base.id ~= 2 and G.hand.highlighted[1].base.id ~= 14 and G.hand.highlighted[1].ability.effect ~= 'Stone Card'
		end,
		use = function(card, area, copier)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    local card = G.hand.highlighted[i]
					
                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
					local id = card.base.id
					local c2s = id / 2
					local cAs = id % 2
					for i = 1, c2s do 
						local _card = copy_card(card, nil, nil, G.playing_card)
						_card:set_base(G.P_CARDS[suit_prefix..'2'])
						_card:add_to_deck()
						G.deck.config.card_limit = G.deck.config.card_limit + 1
						table.insert(G.playing_cards, _card)
						G.hand:emplace(_card)
						_card.states.visible = nil
						G.E_MANAGER:add_event(Event({
							func = function()
								_card:start_materialize()
								return true
							end
						})) 
					end
					
					for i = 1, cAs do 
						local _card = copy_card(card, nil, nil, G.playing_card)
						_card:set_base(G.P_CARDS[suit_prefix..'A'])
						_card:add_to_deck()
						G.deck.config.card_limit = G.deck.config.card_limit + 1
						table.insert(G.playing_cards, _card)
						G.hand:emplace(_card)
						_card.states.visible = nil
						G.E_MANAGER:add_event(Event({
							func = function()
								_card:start_materialize()
								return true
							end
						})) 
					end
					
					card:start_dissolve()
					return true
				end }))
            end  
		end,
		loc_def = function(self)
			return { }
		end,
	}
}

local tarots = {
	home = {
		name = "Home",
		text = {
			"{C:attention}+#1#{} hand size",
			"next round"
		},
		config = { extra = { h_size = 1 } },
		cost = 3,
		cost_mult = 1,
		discovered = true,
		can_use = function(card) 
			return true
		end,
		use = function(card, area, copier)
			G.hand:change_size(card.ability.extra.h_size)
			G.GAME.round_resets.temp_handsize = (G.GAME.round_resets.temp_handsize or 0) + card.ability.extra.h_size
			
		end,
		loc_def = function(card)
			return { card.config.extra.h_size }
		end,
	},
	solar = {
		name = "Solar",
		text = {
			"Enhances {C:attention}#1#{} selected card",
			"into a random {C:attention}Enhancement{}"
		},
		config = { max_highlighted = 2, min_highlighted = 1 },
		cost = 3,
		cost_mult = 1,
		discovered = true,
		can_use = function(card) 
            return card.ability.consumeable.max_highlighted >= #G.hand.highlighted and #G.hand.highlighted >= card.ability.consumeable.min_highlighted
		end,
		use = function(card, area, copier)
            for i=1, #G.hand.highlighted do 
				local card_high = G.hand.highlighted[i]
				card_high:flip()
				card_high:set_ability(get_random_enhancement('eva_tarot_solar', true), nil, true)
				card_high:flip()
				--G.hand:unhighlight_all()
            end
			return true
		end,
		loc_def = function(card)
			return { card.config.max_highlighted, card.config.min_highlighted }
		end,
	},
	
	--[[
	wheel_of_failures = {
		name = "Wheel of Failures",
		text = {
			"#1#% (#2# + #3#)"
		},
		config = { start_percent = 25, add_percent = 12 },
		cost = 3,
		cost_mult = 1,
		discovered = true,
		can_use = function(card) 
            return true
		end,
		use = function(card, area, copier)
			if not G.GAME.starting_params.eva_wheel_of_failure_percent then
				G.GAME.starting_params.eva_wheel_of_failure_percent = 25
			end
			
			if pseudorandom('endlessloop') < G.GAME.starting_params.wheel_of_failure_percent/100 then
				G.GAME.starting_params.wheel_of_failure_percent = card.config.start_percent
			else
				if G.GAME.starting_params.wheel_of_failure_percent <= 25 then
					ease_dollars(3)
				elseif G.GAME.starting_params.wheel_of_failure_percent <= 37 then
				
				elseif G.GAME.starting_params.wheel_of_failure_percent <= 49 then
				
				elseif G.GAME.starting_params.wheel_of_failure_percent <= 61 then
				
				elseif G.GAME.starting_params.wheel_of_failure_percent <= 73 then
				
				elseif G.GAME.starting_params.wheel_of_failure_percent <= 85 then
				
				elseif G.GAME.starting_params.wheel_of_failure_percent <= 97 then
				
				--elseif wheel_of_failure_percent <= 109 then
				-- ??? what do you expect there?
				end
				G.GAME.starting_params.wheel_of_failure_percent = G.GAME.starting_params.wheel_of_failure_percent + card.config.add_percent
			end
			return true
		end,
		loc_def = function(card)
			return { G.GAME.starting_params.wheel_of_failure_percent, card.config.start_percent, card.config.add_percent }
		end,
	}
	--]]
}

function SMODS.INIT.EvaJokers()
    G.localization.misc.dictionary.eva_balance = "Balance"
    G.localization.misc.dictionary.eva_repeat  = "Repeat!"
    G.localization.misc.dictionary.eva_weak    = "Downgrade!"
    --G.localization.misc.dictionary.eva_bingo   = "Good!"
    G.localization.misc.dictionary.eva_addtag  = "+ Tag!"
    G.localization.misc.dictionary.eva_detach  = "Detach!"
    G.localization.misc.dictionary.eva_broken  = "Broken?!!"
    G.localization.misc.dictionary.eva_reroll  = "Reroll"
    G.localization.misc.dictionary.eva_charge  = "Charge!"
    G.localization.misc.dictionary.eva_dataminer = "Hacked!"
    G.localization.misc.dictionary.eva_science = "Great Scott!"
	init_localization()

    -- Create and register jokers
    for k, v in pairs(jokers) do 
        local joker = SMODS.Joker:new(
			v.ability_name or ('Eva ' .. v.name), 	-- Joker ID
			v.slug or k, 							-- name
			v.config, 								-- params
			{ x = 0, y = 0 },						-- pos 
			{ name = v.name, text = v.text }, 		-- localization
			v.rarity, v.cost, v.unlocked, v.discovered, v.blueprint_compat, v.eternal_compat, v.effect, v.atlas, v.soul_pos)
        joker:register()
		
        if not v.atlas then --if atlas=nil then use single sprites. In this case you have to save your sprite as slug.png (for example j_examplejoker.png)
            SMODS.Sprite:new(
				'j_' .. k, 
				SMODS.findModByID("EvaJokers").path, 
				'j_eva_' .. k .. '.png', 
				71, 95, "asset_atli")
                :register()
        end

        --add jokers calculate function:
        if v.calculate then SMODS.Jokers[joker.slug].calculate = v.calculate end
		if v.yes_pool_flag then SMODS.Jokers[joker.slug].yes_pool_flag = v.yes_pool_flag end
		SMODS.Jokers[joker.slug].loc_def = v.loc_def
    end
	
    -- Spectrals
    for k, v in pairs(spectrals) do 
        local spectral = SMODS.Spectral:new(
			v.ability_name or ('Eva ' .. v.name), 	-- ID
			v.slug or k, 							-- name
			v.config, 								-- params
			{ x = 0, y = 0 },						-- pos 
			{ name = v.name, text = v.text }, 		-- localization
			v.cost, v.consumeable, v.discovered, v.atlas)
        spectral:register()
		
        if not v.atlas then --if atlas=nil then use single sprites. In this case you have to save your sprite as slug.png (for example j_examplejoker.png)
            SMODS.Sprite:new(
				'c_' .. k, 
				SMODS.findModByID("EvaJokers").path, 
				'c_eva_' .. k .. '.png', 
				71, 95, "asset_atli")
                :register()
        end
		
		local _spectral = SMODS.Spectrals[spectral.slug]
        _spectral.can_use = v.can_use 
        _spectral.use = v.use
		_spectral.loc_def = v.loc_def
    end
	
    -- Tarots
    for k, v in pairs(tarots) do 
        local tarot = SMODS.Tarot:new(
			v.ability_name or ('Eva ' .. v.name), 	-- ID
			v.slug or k, 							-- name
			v.config, 								-- params
			{ x = 0, y = 0 },						-- pos 
			{ name = v.name, text = v.text }, 		-- localization
			v.cost, v.cost_mult or 1, v.effect, v.consumeable, v.discovered, v.atlas)
        tarot:register()
		
        if not v.atlas then --if atlas=nil then use single sprites. In this case you have to save your sprite as slug.png (for example j_examplejoker.png)
            SMODS.Sprite:new(
				'c_' .. k, 
				SMODS.findModByID("EvaJokers").path, 
				'c_eva_' .. k .. '.png', 
				71, 95, "asset_atli")
                :register()
        end
		
		local _tarot = SMODS.Spectrals[tarot.slug]
        _tarot.can_use = v.can_use 
        _tarot.use = v.use
		_tarot.loc_def = v.loc_def
    end
	
    -- Challenges
    G.localization.misc.challenge_names.c_mod_evanightonmars 	= "Night on Mars"
    G.localization.misc.challenge_names.c_mod_evatarotnight 	= "Major Arcana"
	
	local id_challenge = 21
    for k, v in pairs(challenges) do 
		table.insert(G.CHALLENGES,id_challenge,v)
		id_challenge = id_challenge + 1
        --G.localization.descriptions.misc.challenge_names.k = v.name
    end
end

-- Initialize deck effect
local Backapply_to_runRef = Back.apply_to_run
function Back.apply_to_run(arg_56_0)
    Backapply_to_runRef(arg_56_0)
	G.GAME.pool_flags.dataminer_appears = true
    if arg_56_0.effect.config.eva_tag_deck      then eva_tag_deck      = true end
end

-- Set blind
local setblind_ref = Blind.set_blind
function Blind.set_blind(blind, reset, silent)
    setblind_ref(blind, reset, silent)
    if eva_tag_deck and reset then
		for i = 1,2 do 	
			local tag_name = get_random_tag('j_eva_tagged')
			local tag = Tag(tag_name)
			if tag_name == 'tag_orbital' then
				local _poker_hands = {}
				for k, v in pairs(G.GAME.hands) do
					if v.visible then _poker_hands[#_poker_hands+1] = k end
				end
				tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed('j_eva_tagged_orbital_tag'))
			end
			add_tag(tag)
		end
	end
end

-- Handle cost increase
local set_costref = Card.set_cost
function Card.set_cost(self)
    set_costref(self)

	-- Tarot expansion ------------
	if self.ability.set == "Tarot" and self.ability.consumeable and self.ability.consumeable.max_highlighted and G and G.jokers and G.jokers.cards then 
		for _, v in pairs(G.jokers.cards) do
			if v.ability.name == "Eva Tarot Expansion" then
				if not self.ability.consumeable.max_highlighted_save then self.ability.consumeable.max_highlighted_save = self.ability.consumeable.max_highlighted end
				self.ability.consumeable.max_highlighted = self.ability.consumeable.max_highlighted_save + 1
			end
		end 
	end
	----------------------------------
	
	
	if G.playing_cards then
		--if self.ability.name == "Eva Maroon" then recalculate_maroon_joker(self) end
		
		if self.ability.name == "Eva Golden Idol" then
			-- Randomize start card
			local _card = get_random_card('eva_golden_idol' .. i)
			if _card then 
				self.ability.extra.idol_suit = _card.base.suit
				self.ability.extra.idol_id   = _card.base.id
				self.ability.extra.idol_rank = rank_name(_card.base.id)
			end
		end
		
		--[[ Bingo!
		if self.ability.name == "Eva Bingo" then
			-- Randomize start rank sequence
			self.ability.extra.ranks = '';
			for i = 1, 5 do 
				local bingo_card = get_random_card('eva_bingo_rank' .. i)
				if bingo_card then 
					self.ability.extra.rank_list[i] = bingo_card.base.id
					self.ability.extra.ranks = (i == 1 and '' or (self.ability.extra.ranks .. '-')) .. rank_to_string(bingo_card.base.id)
				end
			end
		end
		--]]
	end
end

-- Sell card
local sell_cardref = Card.sell_card
function Card.sell_card(self)
    sell_cardref(self)
	if self.ability.set == "Joker" then 
        for _, v in pairs(G.jokers.cards) do
            if v.ability.name == "Eva Precognition" and v ~= self then
				local charges_add = 
					v.rarity == 2 and 2 or 
					v.rarity == 3 and 4 or
					v.rarity >  3 and 12 or 1
					
				v.ability.extra.charges = v.ability.extra.charges + charges_add
				card_eval_status_text(v, "extra", nil, nil, nil, {
					message = localize("eva_charge"),
					colour = G.C.PURPLE
				})
            end
        end
	end
end

-- Handle card addition
local add_to_deckref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    if not self.added_to_deck then
        if self.ability.name == "Eva Useless Joker" then
			G.jokers.config.card_limit = G.jokers.config.card_limit + self.ability.extra.j_slots
        end
		
		--[[
        if self.ability.name == "Eva Tarot Expansion" then
			for _, v in pairs(G.jokers.cards) do
				if v.ability.name == "Eva Tarot Expansion" then
					self.ability.consumeable.max_highlighted = self.ability.consumeable.max_highlighted + 1
				end
			end 
			-- self.ability.consumeable and self.ability.consumeable.max_highlighted
        end
		--]]
    end
    add_to_deckref(self, from_debuff)
end

-- Handle card removing
local remove_from_deckref = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    if self.added_to_deck then
        if self.ability.name == "Eva Useless Joker" then
			G.jokers.config.card_limit = G.jokers.config.card_limit - self.ability.extra.j_slots
        end

        -- Sets the pool flag (dataminer should generate once per game)
		if self.ability.name == "Eva Dataminer" then
			G.GAME.pool_flags.dataminer_appears = false
        end
			
    end

    remove_from_deckref(self, from_debuff)
end

-- Any fulldeck jokers
local updateref = Card.update
function Card:update(dt)
	updateref(self, dt)
    if G.STAGE == G.STAGES.RUN then
        if self.ability.name == "Eva Maroon" 		then recalculate_maroon_joker(self) end
        if self.ability.name == "Eva Simple Joker"	then recalculate_simple_joker(self) end
	end
end

----------------------------------------------
------------MOD CODE END----------------------
