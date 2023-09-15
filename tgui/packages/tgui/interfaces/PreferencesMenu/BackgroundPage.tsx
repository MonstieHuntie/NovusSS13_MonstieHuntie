import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';
import { PreferencesMenuData, RandomSetting, ServerData, createSetPreference } from './data';
import { filterMap } from 'common/collections';
import { useRandomToggleState } from './useRandomToggleState';
import { PreferenceList, CLOTHING_CELL_SIZE, CLOTHING_SIDEBAR_ROWS } from './MainPage';

export const BackgroundPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const [randomToggleEnabled] = useRandomToggleState(context);

  return (
    <ServerPreferencesFetcher
      render={(serverData: ServerData | null) => {
        const currentSpeciesData =
          serverData?.species[data.character_preferences.misc.species];

        const contextualPreferences =
          data.character_preferences.secondary_features || [];

        const mainFeatures = [
          ...((data.character_preferences.clothing &&
            Object.entries(data.character_preferences.clothing)) ||
            []),
          ...Object.entries(data.character_preferences.features).filter(
            ([featureName]) => {
              if (!currentSpeciesData) {
                return false;
              }

              return (
                currentSpeciesData.enabled_features.indexOf(featureName) !== -1
              );
            }
          ),
        ];

        const randomBodyEnabled =
          data.character_preferences.non_contextual.random_body !==
            RandomSetting.Disabled || randomToggleEnabled;

        const getRandomization = (
          preferences: Record<string, unknown>
        ): Record<string, RandomSetting> => {
          if (!serverData) {
            return {};
          }

          return Object.fromEntries(
            filterMap(Object.keys(preferences), (preferenceKey) => {
              if (
                serverData.random.randomizable.indexOf(preferenceKey) === -1
              ) {
                return undefined;
              }

              if (!randomBodyEnabled) {
                return undefined;
              }

              return [
                preferenceKey,
                data.character_preferences.randomization[preferenceKey] ||
                  RandomSetting.Disabled,
              ];
            })
          );
        };

        const randomizationOfMainFeatures = getRandomization(
          Object.fromEntries(mainFeatures)
        );

        const backgroundPreferences = {
          ...data.character_preferences.background,
        };

        return (
          <Stack
            height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE * 1.25}px`}>
            <Stack.Item fill>
              <Stack vertical fill>
                <Stack.Item>
                  <CharacterControls
                    gender={data.character_preferences.misc.gender}
                    handleOpenSpecies={props.openSpecies}
                    handleRotate={() => {
                      act('rotate');
                    }}
                    setGender={createSetPreference(act, 'gender')}
                    showGender={
                      currentSpeciesData ? !!currentSpeciesData.sexes : true
                    }
                    showSpecies={
                      !serverData?.ghost_role_data[data.active_slot_key]
                        ?.forced_species
                    }
                  />
                </Stack.Item>

                <Stack.Item grow>
                  <CharacterPreview
                    height="100%"
                    id={data.character_preview_view}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <PreferenceList
              act={act}
              randomizations={getRandomization(backgroundPreferences)}
              preferences={backgroundPreferences}
            />
          </Stack>
        );
      }}
    />
  );
};
